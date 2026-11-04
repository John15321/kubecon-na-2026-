# 02 - Kubernetes on Flatcar

Boot a Flatcar VM and bring up a single-node kubeadm cluster. Flatcar has
no package manager, so `kubeadm`, `kubelet`, and `kubectl` come from a
**systemd-sysext** image merged into the read-only `/usr` at boot.

## Prerequisites

Same as folder 01 (`qemu-system-x86_64`, `curl`, `ssh-keygen`, `docker`,
`tmux`), plus network access to `extensions.flatcar.org` and
`registry.k8s.io`.

## Run it

```
./run.sh
```

The first run downloads the image and caches it. The VM disk keeps cluster
state across runs, so a second `./run.sh` resumes the existing cluster. Run
`./reset.sh` first for a fresh cluster. `reset.sh` deletes only the working
disk copy, so the next run restores from the local cache in seconds instead
of re-downloading.

## Boot and SSH together

```
./demo-tmux.sh
```

Top pane boots the VM. Bottom pane waits for SSH, then gives you a prompt.
`Ctrl-b d` detaches. Kill a stuck session with
`tmux kill-session -t flatcar-k8s-demo`.

## What to show, once SSH'd in

`kubeadm init` already ran during boot. Run these in order:

```
which kubeadm kubelet kubectl    # present, with no package manager
systemd-sysext status            # the kubernetes extension is merged
kubectl get nodes                # the node is NotReady (no CNI yet)
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.28.10/kube-flannel.yml
kubectl get nodes                # now Ready
kubectl get pods -A              # control plane and Flannel are running
```

The kubeconfig is already at `/home/core/.kube/config`, so no `--kubeconfig`
flag is needed.

Optional: remove the control-plane taint to run a workload on this single
node:

```
kubectl taint node flatcar-demo node-role.kubernetes.io/control-plane:NoSchedule-
kubectl apply -f app-demo.yaml
```

## Notes

- **Kubernetes version is pinned to `v1.37.1`.** `v1.37.2` crashes on
  start. Do not drop the `--kubernetes-version` flag without re-checking.
- **CNI is Flannel `v0.28.10`**, pinned so the command cannot change
  between rehearsal and recording.
- The VM boots with 4GB RAM and 2 vCPUs, which `kubeadm` requires.
- `config.bu` is the Butane source shown on stage. The SSH key is
  substituted in at run time, same as folder 01.
- GPG verification is off by default. Set `VERIFY_GPG=1` to turn it on.
