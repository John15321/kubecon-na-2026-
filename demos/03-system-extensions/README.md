# 03 - System extensions (sysexts)

Flatcar's `/usr` is read-only and there is no package manager. A
**systemd-sysext** is a squashfs image that systemd merges over `/usr` at
boot, so you can add software without touching the base OS. This folder
takes the official Kubernetes sysext, lets Ignition fetch it on boot, and
shows `kubeadm`, `kubelet`, and `kubectl` appear on an otherwise untouched
system.

This is the mechanism folder 04 relies on. Here we stop once the binaries
are present; folder 04 goes on to bootstrap a real cluster with them.

## Prerequisites

Same as folder 01 (`qemu-system-x86_64`, `curl`, `ssh-keygen`, `docker`,
`tmux`), plus network access to `extensions.flatcar.org` at boot — Ignition
downloads the sysext while the VM is provisioning.

## Run it

```
./run.sh
```

The first run downloads the Flatcar image and wrapper script and caches
them. Boot output streams to this terminal. Press `Ctrl-A X` to quit QEMU.

## SSH in

Open a second terminal. Wait for the login prompt, then run:

```
ssh -i ssh/demo_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 core@localhost
```

## What to show, once SSH'd in

```
systemd-sysext status            # the kubernetes extension is merged
which kubeadm kubelet kubectl    # present, with no package manager
kubeadm version                  # the version pinned in config.bu
cat /etc/os-release              # the base OS is unchanged underneath
```

## Record boot and SSH together

```
./demo-tmux.sh
```

Two panes: the left boots the VM, the right waits for SSH and then gives you
a live prompt. `Ctrl-b` then an arrow key moves between panes. `Ctrl-b d`
detaches. Kill a stuck session with `tmux kill-session -t flatcar-sysext-demo`.

## Offline fallback

If the VM has no network at boot, Ignition cannot fetch the sysext. In that
case, delete the `/etc/extensions/kubernetes.raw` file entry from
`config.bu`, boot, then copy the image in by hand and re-merge:

```
# on the host, download once:
curl -L -O https://extensions.flatcar.org/extensions/kubernetes-v1.37.1-x86-64.raw

# copy it into the running VM:
scp -i ssh/demo_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -P 2222 kubernetes-v1.37.1-x86-64.raw core@localhost:/tmp/kubernetes.raw

# inside the VM:
sudo cp /tmp/kubernetes.raw /etc/extensions/kubernetes.raw
sudo systemctl restart systemd-sysext
```

## Notes

- **Pinned to Kubernetes `v1.37.1`**, the same version folder 04 uses, so
  the sysext story is consistent across both folders.
- `config.bu` is the Butane source shown on stage. It holds a
  `__SSH_PUBLIC_KEY__` placeholder; `run.sh` generates a throwaway keypair
  under `ssh/` (gitignored) and substitutes the public key before booting,
  same as folder 01.
- GPG verification of the Flatcar download is off by default. Set
  `VERIFY_GPG=1` to turn it on. It covers the Flatcar image and wrapper
  only, not the sysext that Ignition fetches at boot.
