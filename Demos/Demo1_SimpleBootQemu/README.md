Demo 1: Simple Boot in QEMU

Just boot Flatcar in QEMU, poke around, run a container.


1. SETUP (make setup)

  butane --strict < config.bu > config.ign


2. BOOT (make run) -- opens a QEMU window

  ../flatcar_production_qemu_uefi.sh -i config.ign -p 2222 -- -snapshot

  Auto-login in the QEMU window. Just close the window when done.
  -snapshot = base image stays clean between runs.


3. SSH (make ssh) -- from another terminal

  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 core@localhost


4. TRY IT OUT -- inside the VM

  cat /etc/os-release

  docker run --rm hello-world

  ls /usr
  mount | grep /usr


5. CLEAN UP (make clean)

  rm -f config.ign
