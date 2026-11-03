Demo 2: More Interesting Setup

Same QEMU boot but now with Ignition doing real work: hostname, extra user,
systemd services pulling containers on boot.


1. SETUP (make setup)

  butane --strict < config.bu > config.ign


2. BOOT (make run) -- opens a QEMU window, nginx on 8080, ssh on 2223

  ../flatcar_production_qemu_uefi.sh -i config.ign -p 2223 -f 8080:8080 -- -snapshot

  Auto-login in the QEMU window. Just close the window when done.


3. SSH (make ssh) -- from another terminal

  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2223 core@localhost


4. EXPLORE -- inside the VM

  hostname

  docker ps
  curl http://localhost:8080

  journalctl -u hello-world.service

  /opt/bin/welcome.sh


5. VERIFY FROM HOST -- nginx is port-forwarded

  curl http://localhost:8080


6. SSH AS SECOND USER -- from host

  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2223 demo@localhost


7. CLEAN UP (make clean)

  rm -f config.ign
