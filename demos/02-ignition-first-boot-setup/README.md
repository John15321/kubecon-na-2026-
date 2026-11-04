# 02 - Ignition doing real first-boot work

The same QEMU boot as folder 01, but now Ignition sets up the machine before
you ever log in: it sets the hostname, provisions a second user, stages a
script on disk, and defines two systemd units that pull and run containers
on boot. Everything is declared in `config.bu`; nothing is done by hand
afterwards.

## Prerequisites

Same as folder 01 (`qemu-system-x86_64`, `curl`, `ssh-keygen`, `docker`,
`tmux`), plus network access to Docker Hub (`docker.io`) for the
`hello-world` and `nginx:alpine` images the VM pulls on boot.

## Run it

```
./run.sh
```

The first run downloads the Flatcar image and wrapper script and caches
them. Later runs boot straight away. Boot output streams to this terminal.
The nginx container is forwarded to the host on `:8080`. Press `Ctrl-A X`
to quit QEMU.

## SSH in

Open a second terminal. Wait for the login prompt, then SSH in as either
the default `core` user or the `demo` user Ignition created:

```
ssh -i ssh/demo_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 core@localhost
ssh -i ssh/demo_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 demo@localhost
```

## What to show, once SSH'd in

```
hostname                          # flatcar-demo, set declaratively
cat /etc/passwd | grep demo       # the second user exists
groups demo                       # in the docker and sudo groups
docker ps                         # nginx-demo is running
journalctl -u hello-world.service # the oneshot container ran once on boot
/opt/bin/welcome.sh               # the staged script
```

## Verify from the host

nginx is port-forwarded, so this works from your laptop without SSH:

```
curl http://localhost:8080
```

## Record boot and SSH together

```
./demo-tmux.sh
```

Two panes: the left boots the VM, the right waits for SSH and then gives you
a live prompt. `Ctrl-b` then an arrow key moves between panes. `Ctrl-b d`
detaches. Kill a stuck session with `tmux kill-session -t flatcar-ignition-demo`.

## Notes

- `config.bu` is the Butane source shown on stage. It holds a
  `__SSH_PUBLIC_KEY__` placeholder; `run.sh` generates a throwaway keypair
  under `ssh/` (gitignored) and substitutes the public key for both users
  before booting, same as folder 01.
- The two containers come from Docker Hub on first boot, so that run needs
  network access. `nginx-demo.service` restarts the container if it exits;
  `hello-world.service` is a oneshot that runs once.
- GPG verification of the download is off by default. Set `VERIFY_GPG=1` to
  turn it on.
