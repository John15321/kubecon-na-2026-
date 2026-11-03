HELPER_SCRIPT  = ../flatcar_production_qemu_uefi.sh
K8S_VERSION   ?= v1.33.2
K8S_SYSEXT     = kubernetes-$(K8S_VERSION)-x86-64.raw
SSH_PORT      ?= 2224

.PHONY: all setup run ssh scp-sysext clean

all: setup

$(HELPER_SCRIPT):
	$(MAKE) -C .. download

config.ign: config.bu
	butane --strict < config.bu > $@

$(K8S_SYSEXT):
	curl -L -O https://extensions.flatcar.org/extensions/$(K8S_SYSEXT)

setup: config.ign $(K8S_SYSEXT) $(HELPER_SCRIPT)

run: setup
	$(HELPER_SCRIPT) -i config.ign -p $(SSH_PORT) -- -snapshot -m 4096

ssh:
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $(SSH_PORT) core@localhost

scp-sysext:
	scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $(SSH_PORT) $(K8S_SYSEXT) core@localhost:/tmp/kubernetes.raw

clean:
	rm -f config.ign
