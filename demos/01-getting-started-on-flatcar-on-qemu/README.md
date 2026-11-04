# 01 - Flatcar on QEMU

Boot Flatcar Container Linux under QEMU and SSH into it. This is the
starting point: a plain Flatcar VM with one SSH key authorized.

## Prerequisites

- `qemu-system-x86_64`, `curl`, `ssh-keygen`
- `docker` (runs the Butane transpiler)
- Network access to `stable.release.flatcar-linux.net` and `quay.io`

## Run it

```
./run.sh
```

The first run downloads the Flatcar image and wrapper script (a few hundred
MB) and caches them. Later runs boot straight away. Boot output streams to
this terminal. Press `Ctrl-A X` to quit QEMU.

## SSH in

Open a second terminal. Wait for the login prompt, then run:

```
ssh -i ssh/demo_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 core@localhost
```

Show the OS release to confirm you are on Flatcar:

```
cat /etc/os-release
```

## Record boot and SSH together

```
./demo-tmux.sh
```

This opens a tmux session with two panes. The left pane boots the VM. The
right pane waits for SSH, then gives you a prompt to type the `ssh` command
live. `Ctrl-b` then an arrow key moves between panes. `Ctrl-b d` detaches.
Kill a stuck session with `tmux kill-session -t flatcar-demo`.

Record a cast for playback:

```
asciinema rec demo.cast -c ./demo-tmux.sh
```

Run `./run.sh` once first so the download does not pad the recording.

## Notes

- `config.bu` is the Butane source shown on stage. It holds a
  `__SSH_PUBLIC_KEY__` placeholder. `run.sh` generates a throwaway keypair
  under `ssh/` (gitignored) and substitutes the public key before booting.
- GPG verification of the download is off by default. Set `VERIFY_GPG=1`
  to turn it on.
