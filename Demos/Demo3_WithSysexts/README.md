Demo 3: System Extensions (sysexts)

/usr is read-only on Flatcar. Sysexts let you overlay binaries onto it
without touching the base OS. Here we use the official Kubernetes sysext.

Everything happens on boot via Ignition (needs internet):
  - downloads the kubernetes sysext
  - runs kubeadm init
  - installs flannel CNI
  - deploys 3 nginx replicas
Just SSH in and watch the pods.


1. SETUP (make setup)

  curl -L -O https://extensions.flatcar.org/extensions/kubernetes-v1.33.2-x86-64.raw

  butane --strict < config.bu > config.ign


2. BOOT (make run) -- opens a QEMU window, 4GB RAM for k8s

  ../flatcar_production_qemu_uefi.sh -i config.ign -p 2224 -- -snapshot -m 4096

  Auto-login in the QEMU window. Just close the window when done.
  Give it a minute or two for kubeadm + pod pull.


3. SSH (make ssh) -- from another terminal

  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2224 core@localhost


4. SEE IT RUNNING -- inside the VM

  kubectl get nodes
  kubectl get pods -A
  kubectl get deployment hello

  # watch pods come up if still pulling
  kubectl get pods -w


5. POKE AROUND -- inside the VM

  systemd-sysext status
  journalctl -u kubeadm-init.service
  journalctl -u k8s-setup.service


--- MANUAL FALLBACK (no internet in VM) ---

If offline, comment out the kubernetes.raw and systemd units in config.bu,
then use make scp-sysext and run kubeadm manually.

6. COPY SYSEXT INTO VM (make scp-sysext) -- from host

  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P 2224 kubernetes-v1.33.2-x86-64.raw core@localhost:/tmp/kubernetes.raw


7. INSTALL SYSEXT -- inside the VM

  sudo cp /tmp/kubernetes.raw /etc/extensions/
  sudo systemctl restart systemd-sysext

  kubeadm version
  kubectl version --client


8. CLEAN UP (make clean)

  rm -f config.ign
