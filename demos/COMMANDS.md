# Command reference

Every command shown in the demo, in run order. Use it as a cheat sheet
while presenting or following along. Each folder's `README.md` explains the
same steps in context.

Conventions:

- `$` runs on your laptop.
- `core@...$` runs on the Flatcar node over SSH.
- Folders 01 through 03 run locally under QEMU (no cost).
- Folders 04, 06, 07, 08 share one AWS GPU instance (folder 04 creates it).
- Folder 05 uses its own separate AWS GPU instance.

---

## 01 - Flatcar on QEMU

```
$ ./run.sh                 # boot Flatcar under QEMU (Ctrl-A X quits)
$ ./demo-tmux.sh           # boot + SSH in two panes (for recording)
```

SSH in from a second terminal:

```
$ ssh -i ssh/demo_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 core@localhost
```

Ignition did the work:

```
core@flatcar-demo ~$ cat /etc/os-release                # this is Flatcar
core@flatcar-demo ~$ hostname                           # set declaratively
core@flatcar-demo ~$ groups demo                        # the second user, in docker + sudo
core@flatcar-demo ~$ journalctl -u hello-world.service  # oneshot container, ran once on boot
core@flatcar-demo ~$ /opt/bin/welcome.sh                # staged script
```

The OS is immutable:

```
core@flatcar-demo ~$ mount | grep ' /usr '              # read-only
core@flatcar-demo ~$ sudo touch /usr/test               # fails: read-only file system
core@flatcar-demo ~$ echo ok | sudo tee /etc/test       # /etc is writable
```

---

## 02 - System extensions (sysexts)

```
$ ./run.sh                 # boot; Ignition fetches the k8s sysext (needs network)
$ ./demo-tmux.sh           # boot + SSH in two panes
```

On the node:

```
core@flatcar-sysext-demo ~$ systemd-sysext status            # kubernetes extension merged
core@flatcar-sysext-demo ~$ which kubeadm kubelet kubectl    # present, no package manager
core@flatcar-sysext-demo ~$ kubeadm version
core@flatcar-sysext-demo ~$ cat /etc/os-release              # base OS unchanged underneath
```

---

## 03 - Kubernetes on Flatcar

```
$ ./reset.sh               # optional: start from a fresh cluster
$ ./run.sh                 # boot; kubeadm init runs on first boot
$ ./demo-tmux.sh           # boot + SSH in two panes
```

On the node:

```
core@flatcar-demo ~$ which kubeadm kubelet kubectl
core@flatcar-demo ~$ systemd-sysext status
core@flatcar-demo ~$ kubectl get nodes           # NotReady (no CNI yet)
core@flatcar-demo ~$ kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.28.10/kube-flannel.yml
core@flatcar-demo ~$ kubectl get nodes           # Ready
core@flatcar-demo ~$ kubectl get pods -A
core@flatcar-demo ~$ kubectl apply -f app-demo.yaml
```

---

## 04 - GPU node (shared by 06, 07, 08)

```
$ AWS_PROFILE=<name> ./run.sh      # create the g4dn.xlarge instance (billed)
$ ./demo-tmux.sh                   # launch + SSH in two panes
```

On the node, bring the cluster up:

```
core@flatcar-gpu-demo ~$ systemd-sysext status
core@flatcar-gpu-demo ~$ nvidia-smi
core@flatcar-gpu-demo ~$ kubectl get nodes
core@flatcar-gpu-demo ~$ kubectl apply -f $FLANNEL_URL
core@flatcar-gpu-demo ~$ kubectl taint node flatcar-gpu-demo node-role.kubernetes.io/control-plane:NoSchedule-
core@flatcar-gpu-demo ~$ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
core@flatcar-gpu-demo ~$ helm install gpu-operator --wait --timeout 10m \
    -n gpu-operator --create-namespace nvidia/gpu-operator \
    --set driver.enabled=false --set toolkit.enabled=false \
    --set-json 'dcgmExporter.env=[{"name":"DCGM_EXPORTER_INTERVAL","value":"2000"}]'
core@flatcar-gpu-demo ~$ kubectl get pods -n gpu-operator
```

Confirm a pod can see the GPU:

```
core@flatcar-gpu-demo ~$ kubectl run gpu-test --rm --restart=Never \
    --image=nvidia/cuda:12.6.0-base-ubuntu24.04 \
    --overrides='{"spec":{"containers":[{"name":"gpu-test","image":"nvidia/cuda:12.6.0-base-ubuntu24.04","command":["nvidia-smi"],"resources":{"limits":{"nvidia.com/gpu":"1"}}}]}}' \
    -- nvidia-smi
core@flatcar-gpu-demo ~$ kubectl get node --show-labels | tr ',' '\n' | grep -i nvidia
```

---

## 05 - Driver upgrade in place (separate instance)

```
$ AWS_PROFILE=<name> ./run.sh      # create a second, older instance (billed)
$ ./demo-tmux.sh                   # launch + SSH in two panes
```

On the node:

```
core@flatcar-nvidia-upgrade-demo ~$ systemd-sysext status
core@flatcar-nvidia-upgrade-demo ~$ nvidia-smi                        # 570 branch
core@flatcar-nvidia-upgrade-demo ~$ update_engine_client -status
core@flatcar-nvidia-upgrade-demo ~$ update_engine_client -update      # updates and reboots
# SSH back in after reboot:
core@flatcar-nvidia-upgrade-demo ~$ systemd-sysext status
core@flatcar-nvidia-upgrade-demo ~$ nvidia-smi                        # 580 branch
```

---

## 06 - vLLM inference

```
core@flatcar-gpu-demo ~$ kubectl apply -f vllm-demo.yaml
core@flatcar-gpu-demo ~$ kubectl get pods -w
core@flatcar-gpu-demo ~$ CLUSTER_IP=$(kubectl get svc vllm-demo -o jsonpath='{.spec.clusterIP}')
core@flatcar-gpu-demo ~$ curl http://${CLUSTER_IP}:8000/v1/completions \
    -H "Content-Type: application/json" \
    -d '{"model":"Qwen/Qwen2.5-0.5B-Instruct","prompt":"Flatcar Container Linux is","max_tokens":40}'
```

Optional scheduling beat:

```
core@flatcar-gpu-demo ~$ kubectl scale deployment vllm-demo --replicas=2
core@flatcar-gpu-demo ~$ kubectl get pods
core@flatcar-gpu-demo ~$ kubectl describe pod <pending-pod> | grep -A3 Events   # Insufficient nvidia.com/gpu
core@flatcar-gpu-demo ~$ kubectl scale deployment vllm-demo --replicas=1
```

---

## 07 - DCGM GPU metrics (run with 06)

```
core@flatcar-gpu-demo ~$ DCGM_POD_IP=$(kubectl get pods -n gpu-operator -l app=nvidia-dcgm-exporter -o jsonpath='{.items[0].status.podIP}')
core@flatcar-gpu-demo ~$ CLUSTER_IP=$(kubectl get svc vllm-demo -o jsonpath='{.spec.clusterIP}')
```

Pane A - send requests in a loop:

```
core@flatcar-gpu-demo ~$ while true; do
    curl -s http://${CLUSTER_IP}:8000/v1/completions \
      -H "Content-Type: application/json" \
      -d '{"model":"Qwen/Qwen2.5-0.5B-Instruct","prompt":"Explain Flatcar in one sentence.","max_tokens":30}' \
      -o /dev/null -w "request done\n"
    sleep 2
  done
```

Pane B - watch GPU utilization:

```
core@flatcar-gpu-demo ~$ watch -n1 "curl -s http://${DCGM_POD_IP}:9400/metrics | grep DCGM_FI_DEV_GPU_UTIL"
```

---

## 08 - Triton inference

```
core@flatcar-gpu-demo ~$ kubectl apply -f triton-demo.yaml      # server + client in one apply
core@flatcar-gpu-demo ~$ kubectl get pods -w
core@flatcar-gpu-demo ~$ kubectl logs job/triton-classify       # prints the prediction
```

Re-run the client:

```
core@flatcar-gpu-demo ~$ kubectl delete job triton-classify && kubectl apply -f triton-demo.yaml
```

---

## Teardown (stop AWS billing)

```
$ cd 04-nvidia-driver-on-flatcar-aws && ./teardown.sh
$ cd 05-nvidia-driver-upgrade-in-place && ./teardown.sh
```

---

## Record a folder for playback

```
$ asciinema rec demo.cast -c ./demo-tmux.sh
```
