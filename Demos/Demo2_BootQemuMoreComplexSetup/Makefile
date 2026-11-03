HELPER_SCRIPT  = ../flatcar_production_qemu_uefi.sh
SSH_PORT      ?= 2223

.PHONY: all setup run ssh clean

all: setup

$(HELPER_SCRIPT):
	$(MAKE) -C .. download

config.ign: config.bu
	butane --strict < config.bu > $@

setup: config.ign $(HELPER_SCRIPT)

run: setup
	$(HELPER_SCRIPT) -i config.ign -p $(SSH_PORT) -f 8080:8080 -- -snapshot

ssh:
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $(SSH_PORT) core@localhost

clean:
	rm -f config.ign
