---
marp: true
theme: flatcar
paginate: true
size: 16:9
title: "Your GPU Nodes Deserve Better: Flatcar Container Linux for AI Workloads"
author: Jan Bronicki, Sayan Chowdhury
---

<!-- _class: cover -->
<!-- _paginate: false -->

# Your GPU Nodes Deserve Better: Flatcar Container Linux for AI Workloads

## KubeCon + CloudNativeCon North America 2026

##### Jan Bronicki & Sayan Chowdhury

---

<!-- _class: sidebar -->

# whoarewe

<div class="pin-tr" style="display: flex; gap: 20px; align-items: center">
  <img class="img-h-xs" src="./assets/logos/external/flatcar-logo-other.png" alt="Flatcar">
</div>

<div class="cols-2" style="align-items: start; gap: 32px; margin-top: 70px">

<div style="text-align: center">

<img style="width: 260px; height: 260px; object-fit: cover; object-position: 50% 50%; border-radius: 6px" src="assets/photo/individual_photos/jan-bronicki.jpeg" alt="Jan Bronicki">

**Jan Bronicki**

<span style="font-size: 24px; line-height: 1.3">Flatcar Maintainer<br>Software Engineer at Microsoft</span>

<span style="font-size: 22px; font-weight: 600"><img src="assets/logos/external/github-white.png" alt="GitHub" style="height: 26px; width: 26px; object-fit: contain; filter: invert(1); vertical-align: middle; margin-right: 8px">@John15321<br><img src="assets/logos/external/linkedin-white.svg" alt="LinkedIn" style="height: 26px; width: 26px; object-fit: contain; filter: invert(1); vertical-align: middle; margin-right: 8px">jan-bronicki</span>

</div>

<div style="text-align: center">

<img style="width: 260px; height: 260px; object-fit: cover; object-position: 50% 35%; border-radius: 6px" src="assets/photo/individual_photos/sayan-chowdhury-2.jpg" alt="Sayan Chowdhury">

**Sayan Chowdhury**

<span style="font-size: 24px; line-height: 1.3">Flatcar Maintainer<br>Software Engineer at Microsoft</span>

<span style="font-size: 22px; font-weight: 600"><img src="assets/logos/external/github-white.png" alt="GitHub" style="height: 26px; width: 26px; object-fit: contain; filter: invert(1); vertical-align: middle; margin-right: 8px">@sayanchowdhury<br><img src="assets/logos/external/linkedin-white.svg" alt="LinkedIn" style="height: 26px; width: 26px; object-fit: contain; filter: invert(1); vertical-align: middle; margin-right: 8px">yudocaa</span>

</div>

</div>

---

<!-- _class: agenda -->

# Agenda

- The community behind Flatcar
- Flatcar in five minutes, live in a VM
- sysexts and Kubernetes, live in a VM
- Release channels
- The GPU node problem: NVIDIA drivers as sysexts, live on AWS
- Live: an LLM, GPU metrics, and Triton on Flatcar

---

<!-- _class: section -->

# Community Stewarded

## What that means, and who we are

---

<!-- _class: sidebar -->

# Community stewarded

- **Fully open, fully free:** Apache 2.0, public roadmap, public issue tracker
- **No single owner:** the project and trademark belong to the CNCF and the Linux Foundation
- **CNCF project:** neutral governance under the Cloud Native Computing Foundation
- **You can join:** SIG meetings are public; anyone can propose changes or maintain

<div class="cncf-banner">
  <p class="cncf-banner-caption">Flatcar is a <strong>CNCF</strong> project</p>
  <img src="assets/logos/external/cncf-banner.png" alt="Cloud Native Computing Foundation">
</div>

---

<!-- _class: sidebar -->

# The community

<div style="position: relative; width: 100%; height: 620px; margin-top: 4px">
  <img style="position: absolute; left: -4%; top: -2%; width: 42%; box-shadow: 0 10px 26px rgba(0,0,0,.32)" src="assets/photo/group_photos/image13.jpeg" alt="">
  <img style="position: absolute; left: 50%; top: -4%; width: 46%; box-shadow: 0 10px 26px rgba(0,0,0,.32)" src="assets/photo/group_photos/image16.jpeg" alt="">
  <img style="position: absolute; left: 22%; top: 4%;  width: 42%; box-shadow: 0 10px 26px rgba(0,0,0,.32); z-index: 2" src="assets/photo/group_photos/image14.jpeg" alt="">
  <img style="position: absolute; left: 0%; top: 36%; width: 42%; box-shadow: 0 10px 26px rgba(0,0,0,.32); z-index: 2" src="assets/photo/group_photos/image17.jpeg" alt="">
  <img style="position: absolute; left: 58%; top: 22%; width: 42%; box-shadow: 0 10px 26px rgba(0,0,0,.32); z-index: 2" src="assets/photo/group_photos/image18.jpeg" alt="">
  <img style="position: absolute; left: 18%; top: 28%; width: 52%; box-shadow: 0 14px 32px rgba(0,0,0,.38); z-index: 4" src="assets/photo/group_photos/image15.jpeg" alt="">
  <img style="position: absolute; left: 42%; top: 54%; width: 54%; box-shadow: 0 12px 28px rgba(0,0,0,.34); z-index: 3" src="assets/photo/group_photos/image19.jpeg" alt="">
</div>

---

<!-- _class: sidebar -->

# We work with

- **Gentoo** and **Fedora CoreOS**
- **systemd**, **Dracut**, **Grub**, **Afterburn**
- Openwall **oss-security** non-disclosure list
- Co-founders of the **UAPI Group**, cross-distro SIG for image-based Linux

<div class="logo-wall logo-wall-lg" style="grid-template-columns: repeat(4, 1fr); margin-top: 18px">
  <img src="assets/logos/external/gentoo-logo.png" alt="Gentoo" style="transform: translateY(90px); transform-origin: center">
  <img src="assets/logos/external/fedora-coreos-logo.svg" alt="Fedora CoreOS" style="transform: translateY(20px); transform-origin: center">
  <img src="assets/logos/external/clouds/Systemd-logo.svg" alt="systemd" style="transform: scale(1.35) translateY(100px); transform-origin: center">
  <img src="assets/logos/external/linux-logo.png" alt="Linux" style="transform: translateY(30px); transform-origin: center">
</div>

---

<!-- _class: sidebar -->

# Runs everywhere

<div class="logo-wall" style="grid-template-columns: repeat(5, 1fr); grid-template-rows: repeat(4, 1fr); gap: 20px 28px; height: 530px; margin-top: 8px">
  <img src="assets/logos/external/clouds/aws-logo.svg" alt="AWS">
  <img src="assets/logos/external/clouds/azure.svg" alt="Azure">
  <img src="assets/logos/external/clouds/gcp.png" alt="GCP">
  <img src="assets/logos/external/clouds/oracle-cloud-logo.png" alt="Oracle Cloud">
  <img src="assets/logos/external/clouds/openstack.png" alt="OpenStack">

  <img src="assets/logos/external/clouds/stackit-logo.svg" alt="STACKIT">
  <img src="assets/logos/external/clouds/ovhcloud-seeklogo.svg" alt="OVHcloud">
  <img src="assets/logos/external/clouds/scaleway.png" alt="Scaleway">
  <img src="assets/logos/external/clouds/hetzner.png" alt="Hetzner">
  <img src="assets/logos/external/clouds/DigitalOcean_logo.svg" alt="DigitalOcean">

  <img src="assets/logos/external/clouds/akamai-logo.svg" alt="Akamai">
  <img src="assets/logos/external/clouds/exoscale-seeklogo.svg" alt="Exoscale">
  <img src="assets/logos/external/clouds/brightbox-logo.svg" alt="Brightbox">
  <img src="assets/logos/external/clouds/PlusServer-Logo.svg" alt="plusserver">

  <img src="assets/logos/external/clouds/Vmware.svg" alt="VMware">
  <img src="assets/logos/external/clouds/Logo_Proxmox.svg" alt="Proxmox">
  <img src="assets/logos/external/clouds/Qemu_logo.svg" alt="QEMU">
  <img src="assets/logos/external/clouds/kube-virt.svg" alt="KubeVirt">
  <img src="assets/logos/external/clouds/libvirt-logo.svg" alt="libvirt">
  <img src="assets/logos/external/clouds/vagrant.svg" alt="Vagrant">
</div>

---

<!-- _class: sidebar -->

# In production at

<div class="logo-wall logo-wall-lg" style="grid-template-columns: repeat(5, 1fr); grid-template-rows: repeat(3, 1fr); gap: 20px 32px; height: 530px; margin-top: 8px">
  <img src="assets/logos/external/companies/Adobe_Corporate_logo.svg" alt="Adobe">
  <img src="assets/logos/external/companies/atnt.png" alt="AT&T">
  <img src="assets/logos/external/companies/deepl.png" alt="DeepL">
  <img src="assets/logos/external/companies/giantswarm.png" alt="Giant Swarm">
  <img src="assets/logos/external/companies/stackit.png" alt="STACKIT">

  <img src="assets/logos/external/companies/qualys.png" alt="Qualys">
  <img src="assets/logos/external/companies/wipro.png" alt="Wipro">
  <img src="assets/logos/external/companies/equinix.png" alt="Equinix">
  <img src="assets/logos/external/companies/NAV_logo_rød.svg" alt="NAV">
  <img src="assets/logos/external/companies/Finleap_idD9GhopR0_0.svg" alt="Finleap">

  <img src="assets/logos/external/companies/Hedgehog-color-large.svg" alt="Hedgehog">
  <img src="assets/logos/external/companies/digital-science-logo.svg" alt="Digital Science">
  <img src="assets/logos/external/clouds/cloudbasesol-logo_hu_5371da61cf7b0047.webp" alt="Cloudbase Solutions">
  <img src="assets/logos/external/clouds/cloudscale_hu_17df2ff04c9be12e.webp" alt="cloudscale.ch">
  <img src="assets/logos/external/companies/alopeyk.png" alt="Alopeyk" style="max-height: 140px">
</div>

---

<!-- _class: section -->

# What Problem Do We Solve?

## Why the OS is still the odd one out

---

<!-- _class: sidebar -->

# Everything is code. Almost.

<div class="cols-2" style="align-items: start; gap: 40px; margin-top: 12px">

<div>

**Already declarative**

- Dockerfiles
- Kubernetes manifests, Helm charts
- GitOps workflows
- CI/CD pipelines

</div>

<div>

**Still treated differently**

- Host OS installed interactively
- Changed over time
- Repaired manually when it breaks

</div>

</div>

---

# Flatcar?

<img class="pin-mc" style="max-width: 80%; max-height: 60%; object-fit: contain" src="assets/logos/external/other/flatcar-empty.jpeg" alt="An empty flatcar train wagon">

---

# Flatcar!

<img class="pin-mc" style="max-width: 80%; max-height: 60%; object-fit: contain" src="assets/logos/external/other/flatcar-with-cargo.jpeg" alt="A flatcar loaded with shipping containers">

---

<!-- _class: lead -->

# The UX we chose

<div class="cols-2" style="gap: 60px; margin-top: 20px; align-items: end">

<div style="text-align: center">
  <div style="position: relative">
    <img style="display: block; width: 100%; max-height: 380px; object-fit: contain" src="assets/logos/external/other/unix-ux.png" alt="General-purpose Linux">
    <svg viewBox="0 0 100 100" preserveAspectRatio="none" style="position: absolute; inset: 0; width: 100%; height: 100%; pointer-events: none">
      <line x1="2" y1="2" x2="98" y2="98" stroke="#e53935" stroke-width="4"/>
      <line x1="98" y1="2" x2="2" y2="98" stroke="#e53935" stroke-width="4"/>
    </svg>
  </div>
  <p style="font-weight: 700; margin: 12px 0 0 0">General-purpose Linux</p>
</div>

<div style="text-align: center">
  <img style="display: block; margin: 0 auto; max-width: 60%; max-height: 380px; object-fit: contain" src="assets/logos/external/other/flip-switch.png" alt="Flatcar">
  <p style="font-weight: 700; margin: 12px 0 0 0">Flatcar</p>
</div>

</div>

---

<!-- _class: lead -->

# Operating Systems as Code

## A versioned, declarative artifact. Provisioned, not installed.

---

<!-- _class: sidebar -->

# Provisioned, not Installed

<div class="cols-2" style="align-items: start; gap: 40px; margin-top: 12px">

<div>

**Traditional install**

- Interactive choices during setup
- Every machine ends up a little different
- Manual updates, package churn, drift
- No separation between OS and config

</div>

<div>

**Flatcar: provisioned**

- One declarative config, applied at boot
- Every machine identical, reproducible
- Whole-OS atomic updates, no drift
- Same idea as containers, with the config in Git

</div>

</div>

---

# Flatcar Workflow

<img style="display: block; margin: auto; max-width: 100%; max-height: 60%; object-fit: contain" src="assets/diagrams/flatcar-workflow.svg" alt="Flatcar workflow: Butane YAML provisions Cloud, VM, or Bare Metal running Containers">

---

# The Container Philosophy, for the OS

<img style="display: block; margin: auto; height: 540px; max-width: 100%; object-fit: contain" src="assets/diagrams/os-vs-container.svg" alt="Containers: Dockerfile, image, container, new tag. Operating system: Butane, Flatcar image, node, new OS release">

---

# What Butane looks like

```yaml
# Butane config header: declares this is a Flatcar config
variant: flatcar
version: 1.0.0

# Drop in a systemd unit. Flatcar installs and starts it at first boot
systemd:
  units:
    - name: nginx.service
      enabled: true
      contents: |
        [Service]
        ExecStart=/usr/bin/docker run --rm -p 80:80 nginx
        [Install]
        WantedBy=multi-user.target
```


---

# Boot it in a VM

```bash
# Transpile Butane to an ignition config (JSON)
$ butane -o config.ign config.bu

# Boot Flatcar in QEMU with the config applied
$ ./flatcar_production_qemu.sh -i config.ign
```


<div class="callout">
The config gets handed to Flatcar as <strong>user-data</strong>. Same channel every major cloud, hypervisor, and bare-metal provisioner uses to seed an instance.
</div>

---

# It came up serving

```console
$ systemctl is-active nginx.service
active

$ curl -sI http://localhost
HTTP/1.1 200 OK
Server: nginx/1.27.3
Content-Type: text/html
```

No login. No post-boot setup. The machine came up already doing its job.

---

<!-- _class: sidebar -->

# Immutable by Design

- **First boot** provisions from config. After that: the base OS doesn't change.
- The OS is **read-only** and **dm-verity protected**.
- **No package updates**: the entire OS updates as one unit.
- Same config + same base image = **identical machine every time**.
- **sysexts** for optional add-ons.

---

# What is Immutable?

<img style="display: block; margin: 0 auto; height: 540px; max-width: 100%; object-fit: contain" src="assets/diagrams/immutable-layers.svg" alt="Block diagram: writable workloads, config and data on top of the read-only, dm-verity protected OS image, sysexts and boot layer">

<div class="pin-br" style="display: flex; gap: 6px; bottom: 22px; right: 80px; font-size: 13px; font-weight: 700">
  <span style="border: 2px dashed #12172B; border-radius: 4px; padding: 2px 10px; background: #fff; color: #12172B">Writable: yours</span>
  <span style="border: 2px solid #12172B; border-radius: 4px; padding: 2px 10px; background: #09BAC8; color: #12172B">Read-only: Flatcar's</span>
</div>

---

<!-- _class: sidebar -->

# A/B Updates

<div class="ab-slide">
<div class="ab-wrap">
  <div class="ab-stack">
    <div class="ab-card">
      <div class="ab-title"><span class="ab-num">1</span>Fresh install</div>
      <div class="ab-slots">
        <div class="ab-slot active"><span class="ab-label">A</span><span class="ab-ver">1.2.3</span></div>
        <div class="ab-slot passive"><span class="ab-label">B</span><span class="ab-ver">1.2.3</span></div>
      </div>
      <div class="ab-caption">Image ships both slots identical. Only true at first boot.</div>
    </div>
    <div class="ab-card">
      <div class="ab-title"><span class="ab-num">2</span>Update staged</div>
      <div class="ab-slots">
        <div class="ab-slot active"><span class="ab-label">A</span><span class="ab-ver">1.2.3</span></div>
        <div class="ab-slot staged"><span class="ab-label">B</span><span class="ab-ver">1.2.4</span></div>
      </div>
      <div class="ab-caption">New image written over the passive slot. No downtime.</div>
    </div>
    <div class="ab-card">
      <div class="ab-title"><span class="ab-num">3</span>Reboot swaps</div>
      <div class="ab-slots">
        <div class="ab-slot passive"><span class="ab-label">A</span><span class="ab-ver">1.2.3</span></div>
        <div class="ab-slot active"><span class="ab-label">B</span><span class="ab-ver">1.2.4</span></div>
      </div>
      <div class="ab-caption">Boot flips to B. If it fails, reboot back to A at 1.2.3.</div>
    </div>
    <div class="ab-card">
      <div class="ab-title"><span class="ab-num">4</span>Steady running</div>
      <div class="ab-slots">
        <div class="ab-slot passive"><span class="ab-label">A</span><span class="ab-ver">1.2.3</span></div>
        <div class="ab-slot active"><span class="ab-label">B</span><span class="ab-ver">1.2.4</span></div>
      </div>
      <div class="ab-caption">B live. A untouched: it's your rollback target.</div>
    </div>
    <div class="ab-card">
      <div class="ab-title"><span class="ab-num">5</span>Next update</div>
      <div class="ab-slots">
        <div class="ab-slot staged"><span class="ab-label">A</span><span class="ab-ver">1.2.5</span></div>
        <div class="ab-slot active"><span class="ab-label">B</span><span class="ab-ver">1.2.4</span></div>
      </div>
      <div class="ab-caption">1.2.5 overwrites the old 1.2.3 on A. Next reboot: A active, B rollback.</div>
    </div>
  </div>
  <div class="ab-cycle-icon" aria-hidden="true">
    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><path d="M 50 12 A 38 38 0 1 1 12 50" fill="none" stroke="#12172B" stroke-width="7" stroke-linecap="round"/><polygon points="12,32 3,52 21,52" fill="#12172B"/></svg>
  </div>
</div>
<div class="ab-cycle">↺ The passive slot is <strong>never auto-synced</strong>. It's your rollback until the next update lands.</div>
</div>

---


# Channels

<img style="display: block; margin: 0 auto 16px; max-width: 100%; max-height: 240px; object-fit: contain" src="assets/logos/external/other/flatcar-release-channels.png" alt="Alpha to Beta to Stable release flow">

- **Alpha**: fully tested, may have incomplete features. Developers.
- **Beta**: production-ready. Canary alongside stable.
- **Stable**: widespread production. Promoted from beta.
- **LTS**: slower-moving track for environments that need it.

<div class="callout">
Every commit runs the full test suite: unit, integration, and product tests across every supported cloud. By the time a version ships, even <strong>Alpha</strong>, it's been through hundreds of runs.
</div>

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 01</p>

# Flatcar on QEMU

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- No installer: the disk image <strong>is</strong> the OS
- Login prompt in seconds
- SSH works with a key Ignition put there

</div>
<div class="demo-term">
<span class="demo-path">demos/01-getting-started-on-flatcar-on-qemu</span>
<code>$ ./demo-tmux.sh</code>
<code class="c"># right pane, once sshd is up:</code>
<code>$ ssh -i ssh/demo_ed25519 \</code>
<code>    -p 2222 core@localhost</code>
<code>$ cat /etc/os-release</code>
</div>
</div>

<!--
Before we prove the nginx story, let's start smaller: a config whose only content is one SSH public key.

Switch to the terminal. Left pane is the serial console, right pane waits for sshd.

While it boots, say: there is no installer step. We downloaded a disk image, handed QEMU a config, and that is the whole procedure. The same image boots on every cloud on the earlier logo slide.

Payoff: SSH in with the key from the config, cat /etc/os-release. Nobody typed a password, nobody clicked through a wizard.

Fallback if the VM won't boot: asciinema play demo.cast in the same folder.
-->

---

# First boot does the work

<p class="lede">Ignition runs <strong>once</strong>, in the initramfs, <strong>before</strong> the real system starts. Users, files, and units already exist when systemd comes up.</p>

<img class="diagram" style="height: 400px" src="assets/diagrams/ignition-first-boot.svg" alt="config.bu is transpiled by butane into config.ign, handed over as user-data; on first boot Ignition creates users, files and systemd units in the initramfs, then systemd starts the units and nginx serves on port 8080">

<div class="legend"><span class="lg-yours">Your config</span><span class="lg-flatcar">Applied by Ignition</span><span class="lg-k8s">Running system</span></div>

<!--
Talk track: the difference from cloud-init is timing. Ignition runs before the root filesystem is switched to, so there is no window where the machine is half configured and serving.

Walk the diagram left to right: Butane is what you write and review in Git. butane turns it into Ignition JSON. The platform hands that over as user-data. Ignition writes users, files, and units, then the normal boot continues.

If Ignition fails, the boot fails. That is a feature: a machine never comes up silently wrong.

Next demo: the same QEMU VM, but the config now does real work.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 02</p>

# Ignition doing real first-boot work

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- Hostname and a second user, set declaratively
- Containers running before anyone logs in
- nginx reachable from the laptop on <code>:8080</code>

</div>
<div class="demo-term">
<span class="demo-path">demos/02-ignition-first-boot-setup</span>
<code>$ ./demo-tmux.sh</code>
<code>$ hostname</code>
<code>$ groups demo</code>
<code>$ docker ps</code>
<code>$ journalctl -u hello-world.service</code>
<code class="c"># back on the laptop:</code>
<code>$ curl http://localhost:8080</code>
</div>
</div>

<!--
Before switching, show config.bu briefly in the editor: two users, two files, two units. That is everything this machine will ever be told.

While it boots: the VM runs with -snapshot, so every run is a genuine first boot. What you see is Ignition doing the work live, not a pre-baked image.

Payoff: curl localhost:8080 from the laptop. No login, no setup, the machine came up already doing its job. Point back at the "It came up serving" slide.
-->

---

# System extensions

<p class="lede">No package manager, read-only <code>/usr</code>. A <strong>sysext</strong> is a squashfs image that systemd <strong>overlays</strong> onto <code>/usr</code> at boot. Add the file: the software appears. Remove it: gone.</p>

<img class="diagram" style="height: 390px" src="assets/diagrams/sysext-merge.svg" alt="kubernetes.raw in /etc/extensions and Flatcar's read-only /usr are merged by systemd-sysext into a single read-only /usr that contains both kubeadm, kubelet, kubectl and Flatcar's own systemd, containerd and docker">

<div class="legend"><span class="lg-yours">Extension you add</span><span class="lg-flatcar">Flatcar base</span><span class="lg-k8s">systemd</span></div>

<!--
Talk track: this answers the question everyone asks at this point. "If /usr is read-only and there is no package manager, how do I install anything?"

A sysext is just a filesystem image. systemd-sysext stacks it on top of /usr with an overlay. The result is still read-only, and the base image underneath is byte-for-byte what we shipped.

This is not Flatcar-specific magic: systemd-sysext is upstream systemd, and the UAPI group we mentioned earlier standardises it across distros.

Lifecycle: drop the file into /etc/extensions, and it is merged. Delete it, restart systemd-sysext, and it is gone. No leftover files, no dependency resolution.

We use Kubernetes as the example because it is the extension this audience cares about most.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 03</p>

# Adding Kubernetes with a sysext

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- <code>kubernetes</code> listed as a merged extension
- kubeadm, kubelet, kubectl on a box with no package manager
- <code>/usr</code> is still read-only

</div>
<div class="demo-term">
<span class="demo-path">demos/03-system-extensions</span>
<code>$ ./demo-tmux.sh</code>
<code>$ systemd-sysext status</code>
<code>$ which kubeadm kubelet kubectl</code>
<code>$ kubeadm version</code>
<code>$ sudo touch /usr/bin/hello</code>
<code class="c"># Read-only file system</code>
</div>
</div>

<!--
Show config.bu first: one file entry pointing at extensions.flatcar.org, and one unit enabled. That is the whole "installation".

While it boots: Ignition downloads the sysext during first boot, so this VM needs network. If the venue Wi-Fi is bad, use the offline fallback in the folder README.

Payoff 1: systemd-sysext status shows the kubernetes extension merged into /usr.
Payoff 2: try to write to /usr and get "Read-only file system". We added software without making the OS mutable.

Bridge: having the binaries is half the job. Next, one more unit turns this into a running cluster.
-->

---

# A Kubernetes node from one config

<p class="lede">Same sysext, plus one systemd unit that runs <code>kubeadm init</code> on first boot. A <code>ConditionPathExists</code> guard makes it run <strong>exactly once</strong>: reboots resume the cluster.</p>

<img class="diagram" style="height: 390px" src="assets/diagrams/k8s-node-boot.svg" alt="config.bu drives first boot automatically: Ignition fetches the Kubernetes sysext, systemd-sysext merges it, kubeadm.service runs kubeadm init once. Then live on stage: apply the Flannel CNI and the node becomes Ready">

<div class="legend"><span class="lg-yours">You</span><span class="lg-flatcar">Flatcar</span><span class="lg-k8s">Kubernetes</span></div>

<!--
Talk track: no special Kubernetes edition of Flatcar exists. It is the same image as the previous demo, with one extra unit.

The guard is ConditionPathExists=!/etc/kubernetes/kubelet.conf. First boot: the file does not exist, kubeadm init runs. Every later boot: the file exists, the unit is skipped, and the existing cluster resumes.

We deliberately leave the CNI as a live step so you can see the node go from NotReady to Ready.

Pinned versions, for the curious: Kubernetes v1.37.1 (v1.37.2 crashes on start), Flannel v0.28.10.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 04</p>

# Kubernetes on Flatcar

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- <code>kubeadm init</code> already ran during boot
- Node goes <strong>NotReady</strong> to <strong>Ready</strong> with one apply
- A workload scheduled on the node

</div>
<div class="demo-term">
<span class="demo-path">demos/04-deploy-kubernetes-with-flatcar</span>
<code>$ ./reset.sh && ./demo-tmux.sh</code>
<code>$ kubectl get nodes</code>
<code class="c"># NotReady: no CNI yet</code>
<code>$ kubectl apply -f &lt;flannel v0.28.10&gt;</code>
<code>$ kubectl get nodes</code>
<code>$ kubectl get pods -A</code>
<code>$ kubectl taint node flatcar-demo \</code>
<code>    node-role.kubernetes.io/control-plane-</code>
<code>$ kubectl apply -f app-demo.yaml</code>
</div>
</div>

<!--
Run reset.sh before the talk, not on stage: it restores a fresh disk from the local cache.

The VM needs 4GB RAM and 2 vCPUs for kubeadm, run.sh sets that.

While kubeadm init finishes in the top pane: the kubeconfig is already in /home/core/.kube/config, written by the same unit, so kubectl works without flags.

The exact Flannel URL is in demos/COMMANDS.md, copy it from there.

Optional: untaint the control plane and apply app-demo.yaml, then curl localhost:30080 on the node (NodePort) to show which pod answered. It is not forwarded to the laptop.

Fallback: asciinema play demo.cast in this folder.
-->

---

<!-- _class: section -->

# GPU Nodes, Done Right

## NVIDIA drivers without giving up immutability

---

# The GPU node problem

- Drivers are tied to the kernel, so every OS update is a risk
- Hand-patched GPU nodes drift apart
- Rolling back a driver on a mutable host is painful

---

# NVIDIA drivers as sysexts

- Driver shipped as a systemd-sysext image, merged over read-only `/usr`
- Pinned per kernel and Flatcar release, versioned like any artifact
- Updated and rolled back **with** the OS, atomically, through A/B

---

# Who owns what on a GPU node

<p class="lede">Flatcar ships the driver and the container toolkit, built against its own kernel. The GPU Operator runs with <code>driver.enabled=false</code> and <code>toolkit.enabled=false</code>: it only does the Kubernetes side.</p>

<img class="diagram" style="height: 390px" src="assets/diagrams/gpu-node-stack.svg" alt="Layer stack from bottom: NVIDIA T4 hardware; Flatcar kernel and /usr built with the driver; NVIDIA driver sysext and container toolkit shipped by Flatcar; GPU Operator components: device plugin, dcgm-exporter, feature discovery; Kubernetes and your GPU workloads on top">

<div class="legend"><span class="lg-flatcar">Flatcar ships it</span><span class="lg-k8s">Kubernetes / GPU Operator</span><span class="lg-yours">Your workload</span><span class="lg-hw">Hardware</span></div>

<!--
Talk track: on a general-purpose distro, the GPU Operator usually compiles and loads the driver at runtime in a privileged container. Every kernel update is a chance for that to break.

On Flatcar the driver is part of the OS release: built against the exact kernel it ships with and tested together in CI. So we turn the Operator's driver and toolkit off, and keep the parts that are genuinely Kubernetes concerns: the device plugin, metrics, and node labels.

The cyan line in the middle is the whole point: the risky part moved from "runtime, on every node" to "build time, once, in CI".

This demo runs on a real AWS g4dn.xlarge with an NVIDIA T4.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 05</p>

# A GPU node on AWS

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- <code>nvidia-smi</code> works on a fresh node: no driver install step
- The driver listed as a merged sysext
- A pod that asks for a GPU gets one

</div>
<div class="demo-term">
<span class="demo-path">demos/05-nvidia-driver-on-flatcar-aws</span>
<code>$ ./demo-tmux.sh</code>
<code>$ systemd-sysext status</code>
<code>$ nvidia-smi</code>
<code class="c"># CNI + untaint, then (full flags: COMMANDS.md)</code>
<code>$ helm install gpu-operator nvidia/gpu-operator \</code>
<code>    --set driver.enabled=false \</code>
<code>    --set toolkit.enabled=false</code>
<code>$ kubectl get pods -n gpu-operator</code>
<code>$ kubectl run gpu-test ... -- nvidia-smi</code>
</div>
</div>

<!--
Start this instance BEFORE the talk with AWS_PROFILE=<name> ./run.sh. Boot plus kubeadm takes minutes, and run.sh reuses a running instance, so demo-tmux.sh on stage just reattaches.

This is real, billed infrastructure (about $0.53/hr). The same instance serves demos 07, 08 and 09. Tear it down after the talk with ./teardown.sh in this folder.

Payoff 1: nvidia-smi on the host, right after boot. Nobody installed a driver.
Payoff 2: the gpu-test pod prints the same nvidia-smi table from inside a container, which proves the device plugin and toolkit wiring.

If time is short, have the GPU Operator installed beforehand and only show kubectl get pods -n gpu-operator.
-->

---

# Driver upgrades ride the OS update

<p class="lede">The driver is built <strong>with</strong> the kernel, so it is upgraded <strong>with</strong> the OS: one atomic A/B update. If the new driver misbehaves, reboot into the old slot.</p>

<img class="diagram" style="height: 390px" src="assets/diagrams/driver-upgrade.svg" alt="Before: Flatcar 4820.0.1 with USR-A active holding kernel and driver 570-open. update_engine writes USR-B and reboots. After: Flatcar 4865.0.0 with USR-B active holding kernel and driver 580-open, USR-A kept as rollback">

<div class="legend"><span class="lg-flatcar">Active slot</span><span class="lg-yours">Passive / rollback slot</span></div>

<!--
Talk track: connect this to the A/B slide from earlier. Nothing new is being invented for GPUs: the driver simply rides along with the normal OS update.

There is no moment where the new kernel boots with the old driver, because they arrive in the same image. And the old pair stays on disk in the other slot, which is your rollback.

Concretely, in this demo: Flatcar alpha 4820.0.1 with the 570-open branch, updated to 4865.0.0 with 580-open.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 06</p>

# NVIDIA driver upgrade in place

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- Before: driver branch <strong>570-open</strong>
- One command: download, apply, reboot
- After: <strong>580-open</strong>, config untouched

</div>
<div class="demo-term">
<span class="demo-path">demos/06-nvidia-driver-upgrade-in-place</span>
<code>$ ./demo-tmux.sh</code>
<code>$ systemd-sysext status</code>
<code>$ nvidia-smi</code>
<code>$ update_engine_client -status</code>
<code>$ update_engine_client -update</code>
<code class="c"># reboots, SSH back in with the same key</code>
<code>$ systemd-sysext status</code>
<code>$ nvidia-smi</code>
</div>
</div>

<!--
This is a SECOND, separate billed instance on an older Flatcar build, so there is a version gap to cross. It does not touch demo 05's cluster. Start it before the talk, and run ./teardown.sh in this folder afterwards.

While the update downloads and the node reboots, go back to the previous slide: the active slot is about to flip from A to B.

Payoff: same nvidia-smi command, new driver version, and we never touched a driver package.

If you are short on time, move this demo to the end; nothing else depends on it.
-->

---

# Scheduling a model onto the GPU

<p class="lede">The device plugin advertises the GPU as a countable resource. A pod that asks for <code>nvidia.com/gpu: 1</code> lands on it, and a second one waits.</p>

<img class="diagram" style="height: 390px" src="assets/diagrams/vllm-scheduling.svg" alt="The vllm-demo Deployment requests one nvidia.com/gpu; kube-scheduler binds it to the Flatcar GPU node, where the device plugin advertises the GPU capacity; the vLLM pod serves Qwen2.5-0.5B on the T4 with an OpenAI-compatible API on port 8000, called with curl">

<div class="legend"><span class="lg-yours">Your workload</span><span class="lg-k8s">Kubernetes / GPU Operator</span></div>

<!--
Talk track: from here on, nothing is Flatcar-specific, and that is the point. Once the node exposes the GPU properly, it is ordinary Kubernetes.

vLLM serves an OpenAI-compatible API, so the curl you are about to see has the same shape as a call to a hosted model, only this one runs on our node.

Model: Qwen2.5-0.5B-Instruct. Small on purpose, so it downloads in a demo-friendly time and fits the T4's 16GB.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 07</p>

# vLLM inference on Flatcar

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- A model generating text on the T4
- An OpenAI-style API, served from our node
- A second replica stuck: <strong>Insufficient nvidia.com/gpu</strong>

</div>
<div class="demo-term">
<span class="demo-path">demos/07-vllm-inference-on-flatcar</span>
<code>$ kubectl apply -f vllm-demo.yaml</code>
<code>$ kubectl get pods -w</code>
<code>$ CLUSTER_IP=$(kubectl get svc vllm-demo \</code>
<code>    -o jsonpath='{.spec.clusterIP}')</code>
<code>$ curl $CLUSTER_IP:8000/v1/completions \</code>
<code>    -H "Content-Type: application/json" \</code>
<code>    -d '{"model":"Qwen/Qwen2.5-0.5B-Instruct",</code>
<code>         "prompt":"Flatcar Container Linux is",</code>
<code>         "max_tokens":40}'</code>
<code>$ kubectl scale deploy vllm-demo --replicas=2</code>
</div>
</div>

<!--
The first start pulls about 1GB of model and can take up to 5 minutes. Pre-pull it before the talk (apply once, wait for Ready). On stage, the apply is then near-instant.

While the pod starts, the startup probe fails with "connection refused". That is expected while the model loads.

Use the Service ClusterIP, not the name: cluster DNS serves pods, not the node's own shell.

Payoff: the completion text coming back live. Then the scheduling beat: scale to 2, the second pod stays Pending with Insufficient nvidia.com/gpu, because there is exactly one T4. Scale back to 1.

Leave vLLM running: the next demo needs it.
-->

---

# Seeing the GPU work

<p class="lede"><code>dcgm-exporter</code> comes with the GPU Operator. It reads GPU counters and serves them as Prometheus metrics on <code>:9400</code>, the same endpoint you would scrape into Grafana.</p>

<img class="diagram" style="height: 300px" src="assets/diagrams/dcgm-metrics.svg" alt="Pane A sends a curl loop of requests to the vLLM pod, which runs inference on the T4 GPU; dcgm-exporter from the GPU Operator reads the GPU every 2 seconds and serves metrics on port 9400, watched in Pane B">

<div class="legend"><span class="lg-yours">Your terminals / workload</span><span class="lg-k8s">GPU Operator</span><span class="lg-hw">Hardware</span></div>

<!--
Talk track: we just made the GPU do work. Now let us see it working, with the observability path you would use in production.

No Prometheus or Grafana on stage, just two terminal panes, so the cause and effect is obvious: left pane sends requests, right pane shows utilization.

One tuning note: we set the exporter interval to 2s for the demo. The default is 30s, which looks frozen under a short burst.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 08</p>

# GPU metrics with DCGM

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- GPU utilization near 0 while idle
- A spike every time a request lands
- Metrics from the GPU Operator, nothing extra installed

</div>
<div class="demo-term">
<span class="demo-path">demos/08-dcgm-metrics-demo</span>
<code>$ ./demo-tmux.sh</code>
<code class="c"># pane A: the curl loop against vLLM</code>
<code>$ while true; do curl -s ... ; sleep 2; done</code>
<code class="c"># pane B: the GPU utilization</code>
<code>$ watch -n1 "curl -s $DCGM_POD_IP:9400/metrics \</code>
<code>    | grep DCGM_FI_DEV_GPU_UTIL"</code>
</div>
</div>

<!--
Precondition: demo 07's vLLM is Running. Set DCGM_POD_IP and CLUSTER_IP first; both commands are in COMMANDS.md.

Start pane B first so the audience sees the idle baseline, then start the loop in pane A.

Run curl on the host, against the exporter pod's IP. The exporter image has no shell or curl.

Payoff: utilization jumps when a request lands, drops between requests.
-->

---

# Not locked to one framework

<p class="lede">Different model, different server, different API, same node. NVIDIA Triton serves a DenseNet image classifier, and the client runs in-cluster as a Job.</p>

<img class="diagram" style="height: 300px" src="assets/diagrams/triton-flow.svg" alt="The triton-classify Job converts an image to a 224 by 224 by 3 tensor and sends it through the triton-demo Service on port 8000 to the Triton server running DenseNet-121 in ONNX on the T4, which answers class 258, Samoyed">

<div class="legend"><span class="lg-yours">Your workload</span><span class="lg-k8s">Kubernetes</span><span class="lg-hw">Hardware</span></div>

<!--
Optional segment: skip it if time is short. Nothing depends on it.

Talk track: vLLM was an LLM behind an OpenAI API. Triton is a vision model behind a tensor API. The node did not need to know either way.

Why the client is a Job, not a curl: Triton wants a raw tensor matching the model's input shape. A tiny Python client does the preprocessing, and it runs in the cluster because Flatcar's host has no Python. Which is the point of a minimal host.
-->

---

<!-- _class: demo -->

<p class="demo-kicker">Live demo · 09 (optional)</p>

# Triton inference on Flatcar

<div class="demo-grid">
<div>

<p class="demo-label">Watch for</p>

- Server and client from a single apply
- The model fetched by an init container
- A correct prediction: <strong>258, Samoyed</strong>

</div>
<div class="demo-term">
<span class="demo-path">demos/09-triton-inference-on-flatcar</span>
<code>$ kubectl apply -f triton-demo.yaml</code>
<code>$ kubectl get pods -w</code>
<code>$ kubectl logs job/triton-classify</code>
<code class="c"># Predicted class index: 258 (Samoyed)</code>
</div>
</div>

<!--
The test image is a Samoyed, and index 258 is "Samoyed" in the DenseNet labels, so the answer is checkably right.

The score printed is a raw logit, not a probability, so values above 1 are normal. Expect someone to ask.

To re-run the client: kubectl delete job triton-classify && kubectl apply -f triton-demo.yaml.

After the talk: run ./teardown.sh in demos/05 (and demos/06) to stop AWS billing.
-->

---

<!-- _class: lead -->

# Try it yourself

## github.com/flatcar/flatcar-demos

<div class="cols-3" style="align-items: start; gap: 40px; font-size: 22px; line-height: 1.5; margin-top: 8px">

<div>

**Local, QEMU, free**

- 01 Flatcar on QEMU
- 02 Ignition first boot
- 03 System extensions
- 04 Kubernetes

</div>

<div>

**AWS, NVIDIA T4**

- 05 GPU node
- 06 Driver upgrade in place

</div>

<div>

**GPU workloads**

- 07 vLLM inference
- 08 DCGM metrics
- 09 Triton inference

</div>

</div>

---

<!-- _class: closing -->
<!-- _paginate: false -->

# Thank you!

<p class="closing-qr-caption"><img src="assets/logos/external/discord-white.svg" alt=""> Join our Discord!</p>

<p class="closing-links">
  <a href="https://flatcar.org"><img src="assets/logos/flatcar-logotype/icon/white/flatcar-icon-white.svg" alt=""> flatcar.org</a>
  <a href="https://github.com/flatcar"><img src="assets/logos/external/github-white.png" alt=""> github.com/flatcar</a>
  <a href="https://discord.gg/PMYjFUsJyq"><img src="assets/logos/external/discord-white.svg" alt=""> discord.gg/PMYjFUsJyq</a>
</p>

<p class="closing-meetings">
  <span><strong>Office hours</strong> · every 2nd Thu, 16:30 CEST</span>
  <span><strong>Dev sync</strong> · every 4th Thu, 16:30 CEST</span>
</p>

<p class="closing-cta"><strong>Everyone welcome.</strong> Users, contributors, or just curious. Ask questions, get help, share what you're building!</p>
