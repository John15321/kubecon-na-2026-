FLATCAR_CHANNEL ?= stable
FLATCAR_VERSION ?= current
IMAGE_NAME      = flatcar_production_qemu_uefi_image.img
EFI_CODE        = flatcar_production_qemu_uefi_efi_code.qcow2
EFI_VARS        = flatcar_production_qemu_uefi_efi_vars.qcow2
HELPER_SCRIPT   = flatcar_production_qemu_uefi.sh
BASE_URL        = https://$(FLATCAR_CHANNEL).release.flatcar-linux.net/amd64-usr/$(FLATCAR_VERSION)

.PHONY: download clean

download: $(IMAGE_NAME) $(EFI_CODE) $(EFI_VARS) $(HELPER_SCRIPT)

$(IMAGE_NAME):
	@echo ">>> Downloading Flatcar $(FLATCAR_CHANNEL) QEMU UEFI image..."
	curl -L -O $(BASE_URL)/$(IMAGE_NAME)
	@echo ">>> Image ready: $(IMAGE_NAME)"

$(EFI_CODE):
	curl -L -O $(BASE_URL)/$(EFI_CODE)

$(EFI_VARS):
	curl -L -O $(BASE_URL)/$(EFI_VARS)

$(HELPER_SCRIPT):
	@echo ">>> Downloading Flatcar QEMU UEFI helper script..."
	curl -L -o $(HELPER_SCRIPT) $(BASE_URL)/$(HELPER_SCRIPT)
	chmod +x $(HELPER_SCRIPT)
	@echo ">>> Helper script ready: $(HELPER_SCRIPT)"

clean:
	rm -f $(IMAGE_NAME) $(EFI_CODE) $(EFI_VARS) $(HELPER_SCRIPT)
