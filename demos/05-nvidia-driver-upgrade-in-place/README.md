# 05 - NVIDIA driver upgrade in place

Boot a **separate** `g4dn.xlarge` instance on the latest Flatcar alpha
build, pinned to NVIDIA driver branch `570-open` at boot. Then flip the
driver to `580-open` **in place, on the same OS build**: edit
`/etc/flatcar/enabled-sysext.conf` and reboot. No `update_engine` OS
version bump involved.

## Why a separate instance

Flatcar alpha **4865.0.0** publishes multiple NVIDIA driver branches
(`570-open` and `580-open`) built against this same OS build/kernel.
Which one is active is just a systemd-sysext selection in
`/etc/flatcar/enabled-sysext.conf` — swapping it and rebooting flips the
driver without an OS version change. This folder boots its own instance so
that swap doesn't touch folder 04's instance, which carries the Kubernetes
and GPU Operator state folders 06-08 depend on.

- Starts on Flatcar alpha **4865.0.0**, driver branch **570-open** (pinned
  via Ignition, even though the same build also offers `580-open`).
- Swaps in place to driver branch **580-open** — same OS build, same boot,
  just a config edit and a reboot.

## Cost and teardown

This is a **second billed instance**, on top of folder 04's. Run this
folder's own `./teardown.sh` when done with this segment. It is independent
of folder 04's teardown.

## Run it

```
AWS_PROFILE=<name> ./run.sh
```

Same identity check, confirmation prompt, `SPOT=1`, and `AWS_SKIP_CONFIRM=1`
options as folder 04.

## Launch and SSH together

```
./demo-tmux.sh
```

## What to show, once SSH'd in

1. The "before" state:
   ```
   systemd-sysext status           # nvidia-drivers-570-open
   nvidia-smi                      # a 570.x driver
   cat /etc/flatcar/enabled-sysext.conf
   ```
2. The mechanism: this build (`4865.0.0`) publishes both `570-open` and
   `580-open` for its own kernel. Which one is live is just that one file.
3. Trigger the swap in place — edit the file, reboot:
   ```
   sudo sed -i 's/nvidia-drivers-570-open/nvidia-drivers-580-open/' /etc/flatcar/enabled-sysext.conf
   sudo systemctl reboot
   ```
4. After the reboot, SSH back in (same key) and show the "after" state:
   ```
   systemd-sysext status           # nvidia-drivers-580-open
   nvidia-smi                      # driver 580.x
   ```

Narrate the point: the driver branch is a sysext selection, not something
baked into the OS version. Flipping it doesn't require an OS update at all
— same Flatcar build throughout.

## Before the real recording

- **Rehearse the swap once, hands-on, before trusting this README.** The
  `sed` + reboot sequence above is this folder's best understanding of the
  mechanism but hasn't been proven live yet — confirm the `580-open`
  sysext actually downloads/merges and `nvidia-smi` reports the new driver
  after reboot. If it's slow, flaky, or needs an extra step (e.g.
  restarting a driver-install service instead of a full reboot), update
  this README and narrate against a pre-recorded clip instead of running
  it live.
- **Re-verify the build number and AMI id close to the event.** The alpha
  channel moves fast; 4865.0.0 may no longer be `current` by showtime.
  Re-check the release list and re-resolve the AMI id if so.

## Notes

- `config.bu` is the Butane source shown on stage. The SSH key is
  substituted in at run time, same as folders 01-03.
- `ssh/aws-state.json` (gitignored) records this folder's own instance,
  separate from folder 04's.
- The AMI id is specific to `us-east-1`. Re-resolve it for another region.
