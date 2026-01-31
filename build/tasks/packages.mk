# Copyright (C) 2022-2024 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(TARGET_REFERENCE_DEVICE), concord)
TEGRAFLASH_PATH := $(BUILD_TOP)/vendor/nvidia/common/r36/tegraflash
T234_BL         := $(BUILD_TOP)/vendor/nvidia/t234/r36/bootloader
CONCORD_BCT     := $(BUILD_TOP)/vendor/nvidia/concord/r36/BCT
CONCORD_FLASH   := $(BUILD_TOP)/device/nvidia/concord/flash_package
COMMON_FLASH    := $(BUILD_TOP)/device/nvidia/tegra-common/flash_package

INSTALLED_KERNEL_TARGET        := $(PRODUCT_OUT)/kernel
INSTALLED_SUPER_EMPTY_TARGET   := $(PRODUCT_OUT)/super_empty.img
INSTALLED_BOOT_TARGET          := $(PRODUCT_OUT)/boot.img
INSTALLED_INITBOOT_TARGET      := $(PRODUCT_OUT)/init_boot.img
INSTALLED_VENDORBOOT_TARGET    := $(PRODUCT_OUT)/vendor_boot.img
INSTALLED_TOS_TARGET           := $(PRODUCT_OUT)/tos-$(if $(filter-out default,$(TARGET_SECURITY_KEYMINT_HAL)),$(TARGET_SECURITY_KEYMINT_HAL),mon-only).img
INSTALLED_TIANOCORE_TARGET     := $(PRODUCT_OUT)/tianocore.bin
INSTALLED_EDK2_DTBO_TARGET     := $(PRODUCT_OUT)/AndroidConfiguration.dtbo

TOYBOX_HOST  := $(HOST_OUT_EXECUTABLES)/toybox
AVBTOOL_HOST := $(HOST_OUT_EXECUTABLES)/avbtool
LPFLASH_HOST := $(HOST_OUT_EXECUTABLES)/lpflash

ifneq ($(TARGET_PREBUILT_KERNEL),)
DTB_PATH := $(dir $(TARGET_PREBUILT_KERNEL))
else ifneq ($(TARGET_KERNEL_PLATFORM_TARGET),)
DTB_PATH := $(abspath $(KERNEL_OUT))
endif

_p3710_package_archive := $(call intermediates-dir-for,ETC,p3710_flash_package)/p3710_flash_package.txz

$(_p3710_package_archive): $(INSTALLED_KERNEL_TARGET) $(INSTALLED_BOOT_TARGET) $(INSTALLED_INITBOOT_TARGET) $(INSTALLED_VENDORBOOT_TARGET) $(TOYBOX_HOST) $(AVBTOOL_HOST) $(INSTALLED_SUPER_EMPTY_TARGET) $(LPFLASH_HOST) $(INSTALLED_TIANOCORE_TARGET) $(INSTALLED_EDK2_DTBO_TARGET) $(INSTALLED_TOS_TARGET)
	@mkdir -p $(dir $@)/tegraflash
	@mkdir -p $(dir $@)/scripts
	@cp $(TEGRAFLASH_PATH)/tegraflash* $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/*_v2 $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/tegraopenssl $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/tegrasign_v3* $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/sw_memcfg_overlay.pl $(dir $@)/tegraflash/
	@cp -R $(TEGRAFLASH_PATH)/pyfdt $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/dtbcheck.py $(TEGRAFLASH_PATH)/t194.py $(TEGRAFLASH_PATH)/t234.py $(dir $@)/tegraflash/
	@cp $(COMMON_FLASH)/*.sh $(dir $@)/scripts/
	@cp $(CONCORD_FLASH)/p3710.sh $(dir $@)/flash.sh
	@LINEAGEVER=$(shell BUILD_TOP=$(abspath $(BUILD_TOP)) python $(COMMON_FLASH)/get_branch_name.py) && \
	$(TOYBOX_HOST) sed -i "s/REPLACEME/$${LINEAGEVER}/" $(dir $@)/flash.sh
	@cp $(CONCORD_FLASH)/flash_android_t234_sdmmc.xml $(dir $@)/
	@cp $(T234_BL)/* $(dir $@)/
	@rm $(dir $@)/tos-optee_t234.img
	@cp $(INSTALLED_TOS_TARGET) $(dir $@)/tos.img
	@rm $(dir $@)/BOOTAA64.efi
	@rm $(dir $@)/uefi_jetson.bin
	@cp $(INSTALLED_TIANOCORE_TARGET) $(dir $@)/uefi_jetson.bin
	@rm $(dir $@)/bpmp_t234-TE950M-A1_prod.bin
	@$(AVBTOOL_HOST) make_vbmeta_image --flags 2 --padding_size 256 --output $(dir $@)/vbmeta_skip.img
	@cp $(INSTALLED_BOOT_TARGET) $(dir $@)/
	@cp $(INSTALLED_INITBOOT_TARGET) $(dir $@)/
	@cp $(INSTALLED_VENDORBOOT_TARGET) $(dir $@)/
	@touch $(dir $@)/super_meta_only.img
	@$(LPFLASH_HOST) $(dir $@)/super_meta_only.img $(INSTALLED_SUPER_EMPTY_TARGET)
	@cp $(PRODUCT_OUT)/AndroidConfiguration.dtbo $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3701-0000-p3737-0000.dtb $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3737-audio-codec-rt5658-40pin.dtbo $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3737-overlay.dtbo $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3701-overlay.dtbo $(dir $@)/
	@cp $(DTB_PATH)/tegra234-carveouts.dtbo $(dir $@)/
	@cp $(CONCORD_BCT)/* $(dir $@)/
	@cp $(CONCORD_FLASH)/tegra234-mb2-bct-scr-p3701-0000-lineage.dts $(dir $@)/
	@rm -f $(dir $@)/*p3767*
	@echo -n boot-recovery > $(dir $@)/misc.txt
	@cd $(dir $@); tar -cJf $(abspath $@) *

$(PRODUCT_OUT)/p3710_flash_package.txz: $(_p3710_package_archive)
	$(hide) cp $< $@

.PHONY: p3710_flash_package
p3710_flash_package: $(PRODUCT_OUT)/p3710_flash_package.txz


_p3766_package_archive := $(call intermediates-dir-for,ETC,p3766_flash_package)/p3766_flash_package.txz

$(_p3766_package_archive): $(INSTALLED_KERNEL_TARGET) $(INSTALLED_BOOT_TARGET) $(INSTALLED_INITBOOT_TARGET) $(INSTALLED_VENDORBOOT_TARGET) $(TOYBOX_HOST) $(AVBTOOL_HOST) $(INSTALLED_SUPER_EMPTY_TARGET) $(LPFLASH_HOST) $(INSTALLED_TIANOCORE_TARGET) $(INSTALLED_EDK2_DTBO_TARGET) $(INSTALLED_TOS_TARGET)
	@mkdir -p $(dir $@)/tegraflash
	@mkdir -p $(dir $@)/scripts
	@cp $(TEGRAFLASH_PATH)/tegraflash* $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/*_v2 $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/tegraopenssl $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/tegrasign_v3* $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/sw_memcfg_overlay.pl $(dir $@)/tegraflash/
	@cp -R $(TEGRAFLASH_PATH)/pyfdt $(dir $@)/tegraflash/
	@cp $(TEGRAFLASH_PATH)/dtbcheck.py $(TEGRAFLASH_PATH)/t194.py $(TEGRAFLASH_PATH)/t234.py $(dir $@)/tegraflash/
	@cp $(COMMON_FLASH)/*.sh $(dir $@)/scripts/
	@cp $(CONCORD_FLASH)/p3766.sh $(dir $@)/flash.sh
	@LINEAGEVER=$(shell BUILD_TOP=$(abspath $(BUILD_TOP)) python $(COMMON_FLASH)/get_branch_name.py) && \
	$(TOYBOX_HOST) sed -i "s/REPLACEME/$${LINEAGEVER}/" $(dir $@)/flash.sh
	@cp $(CONCORD_FLASH)/flash_android_t234_qspi_nvme.xml $(dir $@)/
	@cp $(CONCORD_FLASH)/flash_android_t234_qspi_sd.xml $(dir $@)/
	@cp $(T234_BL)/* $(dir $@)/
	@rm $(dir $@)/tos-optee_t234.img
	@cp $(INSTALLED_TOS_TARGET) $(dir $@)/tos.img
	@rm $(dir $@)/BOOTAA64.efi
	@rm $(dir $@)/uefi_jetson.bin
	@cp $(INSTALLED_TIANOCORE_TARGET) $(dir $@)/uefi_jetson.bin
	@$(AVBTOOL_HOST) make_vbmeta_image --flags 2 --padding_size 256 --output $(dir $@)/vbmeta_skip.img
	@cp $(INSTALLED_BOOT_TARGET) $(dir $@)/
	@cp $(INSTALLED_INITBOOT_TARGET) $(dir $@)/
	@cp $(INSTALLED_VENDORBOOT_TARGET) $(dir $@)/
	@touch $(dir $@)/super_meta_only.img
	@$(LPFLASH_HOST) $(dir $@)/super_meta_only.img $(INSTALLED_SUPER_EMPTY_TARGET)
	@cp $(PRODUCT_OUT)/AndroidConfiguration.dtbo $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3767-0000-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3767-0001-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3767-0003-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3767-0004-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(DTB_PATH)/tegra234-p3767-overlay.dtbo $(dir $@)/
	@cp $(DTB_PATH)/tegra234-carveouts.dtbo $(dir $@)/
	@cp $(CONCORD_BCT)/* $(dir $@)/
	@rm -f $(dir $@)/*p3701*
	@cp $(CONCORD_BCT)/tegra234-mb2-bct-scr-p3701-0000-override.dts $(dir $@)/
	@cp $(CONCORD_FLASH)/tegra234-mb2-bct-scr-p3767-0000-lineage.dts $(dir $@)/
	@echo -n boot-recovery > $(dir $@)/misc.txt
	@cd $(dir $@); tar -cJf $(abspath $@) *

$(PRODUCT_OUT)/p3766_flash_package.txz: $(_p3766_package_archive)
	$(hide) cp $< $@

.PHONY: p3766_flash_package
p3766_flash_package: $(PRODUCT_OUT)/p3766_flash_package.txz


ifeq ($(word 2,$(subst _, ,$(TARGET_PRODUCT))),concord)
BUILT_TARGET_FILES_ZIPROOT := $(call intermediates-dir-for,PACKAGING,target_files)/$(TARGET_PRODUCT)-target_files
$(BUILT_TARGET_FILES_ZIPROOT).zip: $(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/p3710_flash_package.txz $(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/p3766_flash_package.txz

$(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/p3710_flash_package.txz: $(BUILT_TARGET_FILES_ZIPROOT).zip.list $(PRODUCT_OUT)/p3710_flash_package.txz
	@mkdir -p $(dir $@)
	@cp $(PRODUCT_OUT)/p3710_flash_package.txz $@
	@echo $@ >> $(BUILT_TARGET_FILES_ZIPROOT).zip.list

$(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/p3766_flash_package.txz: $(BUILT_TARGET_FILES_ZIPROOT).zip.list $(PRODUCT_OUT)/p3766_flash_package.txz
	@mkdir -p $(dir $@)
	@cp $(PRODUCT_OUT)/p3766_flash_package.txz $@
	@echo $@ >> $(BUILT_TARGET_FILES_ZIPROOT).zip.list
endif
endif
