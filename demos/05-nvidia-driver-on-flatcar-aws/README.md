# 05 - NVIDIA driver on Flatcar (AWS)

Boot a single `g4dn.xlarge` EC2 instance (NVIDIA **T4**) running Flatcar's
alpha channel, with the NVIDIA driver provided by a **systemd-sysext**.
Bring up a single-node kubeadm cluster and install the NVIDIA GPU Operator.

This is the base for the GPU demos. Folders 07, 08, and 09 run on this same
instance.

## Cost and teardown

This creates **real, billed AWS infrastructure** (about $0.53/hr for
`g4dn.xlarge`). This folder has the only `run.sh`/`teardown.sh` for the
shared instance. Run `./teardown.sh` once, after the whole session.

## Prerequisites

- Same tools as folder 04, plus the `aws` CLI, authenticated.
- Permission to create EC2 instances, security groups, and key pairs.
- `g4dn`/`G` instance quota in your region. If `run.sh` fails on quota,
  request an increase for "Running On-Demand G and VT instances".

## Run it

```
./run.sh
```

`run.sh` prints the active AWS account, identity, and region, then asks for
confirmation before it starts billing. Re-running reuses a running instance
instead of launching a second one.

Options:

- `AWS_PROFILE=<name> ./run.sh` picks an AWS CLI profile.
- `AWS_SKIP_CONFIRM=1` skips the confirmation prompt.
- `SPOT=1` requests a cheaper Spot instance. Use it for rehearsal only, not
  the live talk.

## Launch and SSH together

```
./demo-tmux.sh
```

Top pane launches the instance. Bottom pane waits for SSH, then gives you a
prompt. `tmux kill-session -t flatcar-nvidia-demo` kills a stuck session.

## What to show, once SSH'd in

1. Confirm the driver and runtime are merged:
   ```
   systemd-sysext status
   nvidia-smi
   ```
2. Confirm the cluster. `kubeadm init` already ran during boot:
   ```
   systemctl status kubeadm.service
   kubectl get nodes               # NotReady (no CNI yet)
   ```
3. Apply the CNI (`FLANNEL_URL` is set by the node's profile):
   ```
   kubectl apply -f $FLANNEL_URL
   kubectl get nodes               # now Ready
   ```
4. Remove the control-plane taint. The GPU Operator needs this on a
   single-node cluster, or its pods never schedule:
   ```
   kubectl taint node flatcar-gpu-demo node-role.kubernetes.io/control-plane:NoSchedule-
   ```
5. Install the GPU Operator:
   ```
   helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
   helm install gpu-operator --wait --timeout 10m \
       -n gpu-operator --create-namespace nvidia/gpu-operator \
       --set driver.enabled=false --set toolkit.enabled=false \
       --set-json 'dcgmExporter.env=[{"name":"DCGM_EXPORTER_INTERVAL","value":"2000"}]'
   ```
   - `driver.enabled=false` and `toolkit.enabled=false`: Flatcar's sysext
     already provides these. The GPU Operator must not install its own.
   - `DCGM_EXPORTER_INTERVAL=2000`: sets the metric refresh to 2s, which
     folder 08 needs. The default is 30s.
   - `--timeout 10m`: the first install pulls several images. A `context
     deadline exceeded` message means `--wait` timed out, not that the
     install failed. Check `kubectl get pods -n gpu-operator`.
6. Confirm a pod can see the GPU:
   ```
   kubectl run gpu-test --rm --restart=Never \
     --image=nvidia/cuda:12.6.0-base-ubuntu24.04 \
     --overrides='{"spec":{"containers":[{"name":"gpu-test","image":"nvidia/cuda:12.6.0-base-ubuntu24.04","command":["nvidia-smi"],"resources":{"limits":{"nvidia.com/gpu":"1"}}}]}}' \
     -- nvidia-smi
   ```
7. Show the GPU labels the Operator applied automatically:
   ```
   kubectl get node --show-labels | tr ',' '\n' | grep -i nvidia
   ```

## Before the real recording

- **Pre-run the GPU Operator install once, off-camera**, so every image is
  cached and the recorded take comes up fast.
- **Re-run a timed-out install with `helm upgrade --install gpu-operator`**,
  which is idempotent and resumes cleanly.
- **Pin versions close to the event.** The alpha channel moves fast.
  Re-check the AMI and the `nvidia-drivers` / `nvidia-runtime` versions.
  `nvidia-runtime` must be `v1.19.1` or later; `v1.17.9` breaks GPU pods.
- **Support posture, if asked on stage:** this is a Flatcar-documented
  path, but it is **not NVIDIA-certified**. Say exactly that.

## Notes

- `config.bu` is the Butane source shown on stage. It stages
  `vllm-demo.yaml` (folder 07) and `triton-demo.yaml` (folder 09) onto the
  node, so those folders' `kubectl apply` commands need no copy step. Keep
  those inline copies in sync with the folders' own files by hand.
- `ssh/aws-state.json` (gitignored) records the instance id, security
  group, key name, and region for `wait-for-ssh.sh` and `teardown.sh`.
- The AMI id is specific to `us-east-1`. Re-resolve it for another region.
- The root volume is set to 100GB. 16GB is not enough for the sysexts, the
  GPU Operator images, and the vLLM image.
