# 06 - NVIDIA driver upgrade in place

Boot a **separate** `g4dn.xlarge` instance on an older Flatcar build, then
update it live. The NVIDIA driver branch flips from `570-open` to
`580-open` as a side effect of a normal Flatcar OS update.

## Why a separate instance

On Flatcar, the NVIDIA driver is built together with the kernel. Upgrading
the driver means upgrading Flatcar itself through its atomic A/B update.
That needs a version gap to cross, so this folder boots its own instance on
an older build. It does not touch folder 05's instance, which carries the
Kubernetes and GPU Operator state folders 07-09 depend on.

- Starts on Flatcar alpha **4820.0.1**, driver branch **570-open**.
- Updates to **4865.0.0**, driver branch **580-open**.

## Cost and teardown

This is a **second billed instance**, on top of folder 05's. Run this
folder's own `./teardown.sh` when done with this segment. It is independent
of folder 05's teardown.

## Run it

```
AWS_PROFILE=<name> ./run.sh
```

Same identity check, confirmation prompt, `SPOT=1`, and `AWS_SKIP_CONFIRM=1`
options as folder 05.

## Launch and SSH together

```
./demo-tmux.sh
```

## What to show, once SSH'd in

1. The "before" state:
   ```
   systemd-sysext status           # nvidia-drivers-570-open
   nvidia-smi                      # a 570.x driver
   ```
2. The update mechanism:
   ```
   update_engine_client -status    # current version 4820.0.1
   ```
3. Trigger the update. This downloads, applies, and reboots:
   ```
   update_engine_client -update
   ```
4. After the reboot, SSH back in (same key) and show the "after" state:
   ```
   systemd-sysext status           # nvidia-drivers-580-open
   nvidia-smi                      # driver 580.x
   ```

Narrate the point: this is Flatcar's normal update model, not a
GPU-specific trick. The driver moves with the OS.

## Before the real recording

- **Re-verify both build numbers close to the event.** The alpha channel
  moves fast. Re-check the release list and the AMI id.
- **Time the full update and reboot at least once.** If it is slow or
  unpredictable, narrate it against a pre-recorded clip instead of running
  it live.

## Notes

- `config.bu` is the Butane source shown on stage. The SSH key is
  substituted in at run time, same as folders 01-04.
- `ssh/aws-state.json` (gitignored) records this folder's own instance,
  separate from folder 05's.
- The AMI id is specific to `us-east-1`. Re-resolve it for another region.
