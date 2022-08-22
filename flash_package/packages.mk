LOCAL_PATH := $(call my-dir)

TEGRAFLASH_PATH := $(BUILD_TOP)/vendor/nvidia/common/r35/tegraflash
T234_BL         := $(BUILD_TOP)/vendor/nvidia/t234/r35/bootloader
CONCORD_BCT     := $(BUILD_TOP)/vendor/nvidia/concord/r35/BCT
CONCORD_FLASH   := $(BUILD_TOP)/device/nvidia/concord/flash_package
COMMON_FLASH    := $(BUILD_TOP)/device/nvidia/tegra-common/flash_package

INSTALLED_KERNEL_TARGET        := $(PRODUCT_OUT)/kernel
INSTALLED_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img
INSTALLED_SUPER_EMPTY_TARGET   := $(PRODUCT_OUT)/super_empty.img
INSTALLED_TIANOCORE_TARGET     := $(PRODUCT_OUT)/tianocore.bin
INSTALLED_RLAUNCHER_TARGET     := $(PRODUCT_OUT)/AndroidLauncher-recovery.efi
INSTALLED_EDK2_DTBO_TARGET     := $(PRODUCT_OUT)/AndroidConfiguration.dtbo

TOYBOX_HOST  := $(HOST_OUT_EXECUTABLES)/toybox
AVBTOOL_HOST := $(HOST_OUT_EXECUTABLES)/avbtool
MCOPY_HOST   := $(HOST_OUT_EXECUTABLES)/mcopy
MMD_HOST     := $(HOST_OUT_EXECUTABLES)/mmd
MKFSFAT_HOST := $(HOST_OUT_EXECUTABLES)/mformat
LPFLASH_HOST := $(HOST_OUT_EXECUTABLES)/lpflash

include $(CLEAR_VARS)
LOCAL_MODULE        := p3710_flash_package
LOCAL_MODULE_SUFFIX := .txz
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)

_p3710_package_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_p3710_package_archive := $(_p3710_package_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_p3710_package_archive): $(INSTALLED_KERNEL_TARGET) $(INSTALLED_RECOVERYIMAGE_TARGET) $(TOYBOX_HOST) $(AVBTOOL_HOST) $(INSTALLED_SUPER_EMPTY_TARGET) $(MCOPY_HOST) $(MMD_HOST) $(MKFSFAT_HOST) $(LPFLASH_HOST) $(INSTALLED_TIANOCORE_TARGET) $(INSTALLED_RLAUNCHER_TARGET) $(INSTALLED_EDK2_DTBO_TARGET)
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
	@rm $(dir $@)/BOOTAA64.efi
	@rm $(dir $@)/uefi_jetson.bin
	@cp $(INSTALLED_TIANOCORE_TARGET) $(dir $@)/uefi_jetson.bin
	@rm $(dir $@)/bpmp_t234-TE950M-A1_prod.bin
	@$(AVBTOOL_HOST) make_vbmeta_image --flags 2 --padding_size 256 --output $(dir $@)/vbmeta_skip.img
	@cp $(INSTALLED_RECOVERYIMAGE_TARGET) $(dir $@)/
	@touch $(dir $@)/super_meta_only.img
	@$(LPFLASH_HOST) $(dir $@)/super_meta_only.img $(INSTALLED_SUPER_EMPTY_TARGET)
	@cp $(PRODUCT_OUT)/AndroidConfiguration.dtbo $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3737-audio-codec-rt5658-40pin.dtbo $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3737-overlay.dtbo $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3701-overlay.dtbo $(dir $@)/
	@cp $(CONCORD_BCT)/* $(dir $@)/
	@rm -f $(dir $@)/*p3767*
	@dd if=/dev/zero of=$(dir $@)/esp.img bs=1M count=64
	@$(MKFSFAT_HOST) -F -i $(dir $@)/esp.img ::
	@$(MMD_HOST) -i $(dir $@)/esp.img ::/EFI
	@$(MMD_HOST) -i $(dir $@)/esp.img ::/EFI/BOOT
	@$(MCOPY_HOST) -i $(dir $@)/esp.img $(INSTALLED_RLAUNCHER_TARGET) ::/EFI/BOOT/BOOTAA64.efi
	@cd $(dir $@); tar -cJf $(abspath $@) *

include $(BUILD_SYSTEM)/base_rules.mk

include $(CLEAR_VARS)
LOCAL_MODULE        := p3766_flash_package
LOCAL_MODULE_SUFFIX := .txz
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)

_p3766_package_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_p3766_package_archive := $(_p3766_package_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_p3766_package_archive): $(INSTALLED_KERNEL_TARGET) $(INSTALLED_RECOVERYIMAGE_TARGET) $(TOYBOX_HOST) $(AVBTOOL_HOST) $(INSTALLED_SUPER_EMPTY_TARGET) $(MCOPY_HOST) $(MMD_HOST) $(MKFSFAT_HOST) $(LPFLASH_HOST) $(INSTALLED_TIANOCORE_TARGET) $(INSTALLED_RLAUNCHER_TARGET) $(INSTALLED_EDK2_DTBO_TARGET)
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
	@rm $(dir $@)/BOOTAA64.efi
	@rm $(dir $@)/uefi_jetson.bin
	@cp $(INSTALLED_TIANOCORE_TARGET) $(dir $@)/uefi_jetson.bin
	@$(AVBTOOL_HOST) make_vbmeta_image --flags 2 --padding_size 256 --output $(dir $@)/vbmeta_skip.img
	@cp $(INSTALLED_RECOVERYIMAGE_TARGET) $(dir $@)/
	@touch $(dir $@)/super_meta_only.img
	@$(LPFLASH_HOST) $(dir $@)/super_meta_only.img $(INSTALLED_SUPER_EMPTY_TARGET)
	@cp $(PRODUCT_OUT)/AndroidConfiguration.dtbo $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0000-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0001-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0003-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0004-p3768-0000-a0-android.dtb $(dir $@)/
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-overlay.dtbo $(dir $@)/
	@cp $(CONCORD_BCT)/* $(dir $@)/
	@rm -f $(dir $@)/*p3701*
	@cp $(CONCORD_BCT)/tegra234-mb2-bct-scr-p3701-0000-override.dts $(dir $@)/
	@mv $(dir $@)/tegra234-bpmp-3767-0000-a02-3509-a02.dtb $(dir $@)/tegra234-bpmp-3767-0000-3509-a02.dtb
	@dd if=/dev/zero of=$(dir $@)/esp.img bs=1M count=64
	@$(MKFSFAT_HOST) -F -i $(dir $@)/esp.img ::
	@$(MMD_HOST) -i $(dir $@)/esp.img ::/EFI
	@$(MMD_HOST) -i $(dir $@)/esp.img ::/EFI/BOOT
	@$(MCOPY_HOST) -i $(dir $@)/esp.img $(INSTALLED_RLAUNCHER_TARGET) ::/EFI/BOOT/BOOTAA64.efi
	@cd $(dir $@); tar -cJf $(abspath $@) *

include $(BUILD_SYSTEM)/base_rules.mk
