LOCAL_PATH := $(call my-dir)

TEGRAFLASH_PATH := $(BUILD_TOP)/vendor/nvidia/common/r35/tegraflash
T234_BL         := $(BUILD_TOP)/vendor/nvidia/t234/r35/bootloader
CONCORD_BCT     := $(BUILD_TOP)/vendor/nvidia/concord/r35/BCT
CONCORD_FLASH   := $(BUILD_TOP)/device/nvidia/concord/flash_package
COMMON_FLASH    := $(BUILD_TOP)/device/nvidia/tegra-common/flash_package

CAPSULE_PATH    := $(BUILD_TOP)/bootable/tianocore/edk2/BaseTools/Source/Python/Capsule
CAPSULE_CERTS   ?= $(BUILD_TOP)/bootable/tianocore/edk2/BaseTools/Source/Python/Pkcs7Sign
CAPSULE_PRIVATE ?= $(CAPSULE_CERTS)/TestCert.pem
CAPSULE_OTHER   ?= $(CAPSULE_CERTS)/TestSub.pub.pem
CAPSULE_TRUSTED ?= $(CAPSULE_CERTS)/TestRoot.pub.pem

INSTALLED_KERNEL_TARGET    := $(PRODUCT_OUT)/kernel
INSTALLED_TIANOCORE_TARGET := $(PRODUCT_OUT)/tianocore.bin
INSTALLED_EDK2_DTBO_TARGET := $(PRODUCT_OUT)/AndroidConfiguration.dtbo

TOYBOX_HOST  := $(HOST_OUT_EXECUTABLES)/toybox

LINEAGEVER   := $(shell python $(COMMON_FLASH)/get_branch_name.py)

KERNEL_OUT ?= $(PRODUCT_OUT)/obj/KERNEL_OBJ

DTC_HOST    := $(HOST_OUT_EXECUTABLES)/dtc
FDTPUT_HOST := $(HOST_OUT_EXECUTABLES)/fdtput

COMMA := ,
E :=
SPACE := $(E) $(E)

CPP_HOST := $(HOST_OUT_EXECUTABLES)/cpp
$(CPP_HOST):
	ln -sf $(KERNEL_TOOLCHAIN)/$(KERNEL_TOOLCHAIN_PREFIX)cpp.br_real $@

include $(CLEAR_VARS)
LOCAL_MODULE               := TEGRA_BL.Cap
LOCAL_MODULE_CLASS         := ETC
LOCAL_MODULE_RELATIVE_PATH := firmware

_concord_blob_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_concord_blob := $(_concord_blob_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

P3710-0000_SIGNED_PATH := $(_concord_blob_intermediates)/p3710-0000-signed
P3710-0004_SIGNED_PATH := $(_concord_blob_intermediates)/p3710-0004-signed
P3710-0005_SIGNED_PATH := $(_concord_blob_intermediates)/p3710-0005-signed
P3766-0000_SIGNED_PATH := $(_concord_blob_intermediates)/p3766-0000-signed
P3766-0001_SIGNED_PATH := $(_concord_blob_intermediates)/p3766-0001-signed
P3766-0002_SIGNED_PATH := $(_concord_blob_intermediates)/p3766-0002-signed
P3766-0003_SIGNED_PATH := $(_concord_blob_intermediates)/p3766-0003-signed
P3766-0004_SIGNED_PATH := $(_concord_blob_intermediates)/p3766-0004-signed
P3766-0005_SIGNED_PATH := $(_concord_blob_intermediates)/p3766-0005-signed

_p3710-0000_br_bct := $(P3710-0000_SIGNED_PATH)/br_bct_BR.bct
_p3710-0004_br_bct := $(P3710-0004_SIGNED_PATH)/br_bct_BR.bct
_p3710-0005_br_bct := $(P3710-0005_SIGNED_PATH)/br_bct_BR.bct
_p3766-0000_br_bct := $(P3766-0000_SIGNED_PATH)/br_bct_BR.bct
_p3766-0001_br_bct := $(P3766-0001_SIGNED_PATH)/br_bct_BR.bct
_p3766-0002_br_bct := $(P3766-0002_SIGNED_PATH)/br_bct_BR.bct
_p3766-0003_br_bct := $(P3766-0003_SIGNED_PATH)/br_bct_BR.bct
_p3766-0004_br_bct := $(P3766-0004_SIGNED_PATH)/br_bct_BR.bct
_p3766-0005_br_bct := $(P3766-0005_SIGNED_PATH)/br_bct_BR.bct

# Parameters
# $1  Intermediates path
# $2  Partition xml
# $3  BPMP FW variant
# $4  BPMP dtb
# $5  Kernel dtb
# $6  ODM data list
# $7  BL dtbo list
# $8  Device config
# $9  Misc config
# $10 Pinmux config
# $11 Gpioint config
# $12 Pmic config
# $13 Pmc config
# $14 Device prod config
# $15 Prod config
# $16 Scr config
# $17 Wb0sdram config
# $18 Br cmd config
# $19 Uphy config
# $20 Dev params slot 1
# $21 Dev params slot 2
# $22 Mb2 bct config
# $23 Sdram config
# $24 Module board id
# $25 Module sku
# $26 Carrier board id
# $27 Carrier sku
define t234_bl_signing_rule
$(strip $1)/br_bct_BR.bct: $(INSTALLED_KERNEL_TARGET) $(FDTPUT_HOST) $(DTC_HOST) $(INSTALLED_TIANOCORE_TARGET) $(INSTALLED_EDK2_DTBO_TARGET) $(TOYBOX_HOST) $(CPP_HOST)
	@mkdir -p $(strip $1)
	@cp $(CONCORD_FLASH)/$(strip $2) $(strip $1)/
	@cp $(CONCORD_BCT)/* $(strip $1)/
	@cp $(T234_BL)/* $(strip $1)/
	@rm $(strip $1)/BOOTAA64.efi
	@rm $(strip $1)/uefi_jetson.bin
	@cp $(INSTALLED_TIANOCORE_TARGET) $(strip $1)/uefi_jetson.bin
	@mv $(strip $1)/bpmp_t234-$(strip $3)_prod.bin $(strip $1)/bpmp_t234-prod.bin
	@cp $(CONCORD_BCT)/$(strip $4) $(strip $1)/tegra234-bpmp.dtb
	@cp $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/$(strip $5) $(strip $1)/
	@cp $(PRODUCT_OUT)/AndroidConfiguration.dtbo $(strip $1)/
	$(FDTPUT_HOST) -p -t bx $(strip $1)/AndroidConfiguration.dtbo /fragment@0/__overlay__/firmware/uefi/variables/gNVIDIAPublicVariableGuid/TegraPlatformSpec data $(shell printf "p%04d-%04d+p%04d-%04d.android\0" $(strip $(24)) $(strip $(25)) $(strip $(26)) $(strip $(27)) |xxd -p |sed 's/../& /g');
	$(FDTPUT_HOST) -p $(strip $1)/AndroidConfiguration.dtbo /fragment@0/__overlay__/firmware/uefi/variables/gNVIDIAPublicVariableGuid/TegraPlatformSpec runtime;
	$(FDTPUT_HOST) -p $(strip $1)/AndroidConfiguration.dtbo /fragment@0/__overlay__/firmware/uefi/variables/gNVIDIAPublicVariableGuid/TegraPlatformSpec locked;
	echo "NV4" > $(strip $1)/qspi_bootblob_ver.txt
	echo "# R$(word 1,$(subst ., ,$(LINEAGEVER))) , REVISION: $(word 2,$(subst ., ,$(LINEAGEVER)))" >> $(strip $1)/qspi_bootblob_ver.txt
	echo "BOARDID=$(strip $(24)) BOARDSKU=$(strip $(25)) FAB=" >> $(strip $1)/qspi_bootblob_ver.txt
	$(TOYBOX_HOST) date '+%Y%m%d%H%M%S' >> $(strip $1)/qspi_bootblob_ver.txt
	echo "$(shell printf "0x%x" $$(( $(word 1,$(subst ., ,$(LINEAGEVER)))<<16 | $(word 2,$(subst ., ,$(LINEAGEVER)))<<8 )) )" >> $(strip $1)/qspi_bootblob_ver.txt
	python -c 'import zlib; print("%X"%(zlib.crc32(open("'"$(strip $1)/qspi_bootblob_ver.txt"'", "rb").read()) & 0xFFFFFFFF))' > $(strip $1)/crc.txt
	wc -c < $(strip $1)/qspi_bootblob_ver.txt | tr -d '\n' > $(strip $1)/bytes.txt
	echo -n "BYTES:" >> $(strip $1)/qspi_bootblob_ver.txt
	cat $(strip $1)/bytes.txt >> $(strip $1)/qspi_bootblob_ver.txt
	echo -n " CRC32:" >> $(strip $1)/qspi_bootblob_ver.txt
	cat $(strip $1)/crc.txt >> $(strip $1)/qspi_bootblob_ver.txt
	sed -i '/esp.img/d' $(strip $1)/$(strip $(2))
	sed -i '/recovery.img/d' $(strip $1)/$(strip $(2))
	sed -i '/super_meta_only.img/d' $(strip $1)/$(strip $(2))
	sed -i '/tegra234-p.*dtb/d' $(strip $1)/$(strip $(2))
	sed -i '/vbmeta_skip.img/d' $(strip $1)/$(strip $(2))
	cd $(strip $1); PYTHONDONTWRITEBYTECODE=1 PATH=$(HOST_OUT_EXECUTABLES):$(BUILD_TOP)/prebuilts/build-tools/path/linux-x86:$$PATH $(TEGRAFLASH_PATH)/tegraflash.py \
		--chip 0x23 \
		--bl uefi_jetson_with_dtb.bin \
		--applet mb1_t234_prod.bin \
		--concat_cpubl_bldtb \
		--cpubl uefi_jetson.bin \
		--cmd "sign" \
		--cfg $(strip $(2)) \
		--odmdata $(subst $(SPACE),$(COMMA),$(6)) \
		--overlay_dtb AndroidConfiguration.dtbo,$(subst $(SPACE),,$(foreach dtbo,$(strip $(7)),$(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/$(dtbo),)) \
		--bldtb $(strip $(5)) \
		--device_config $(strip $(8)) \
		--misc_config $(strip $(9)) \
		--pinmux_config $(strip $(10)) \
		--gpioint_config $(strip $(11)) \
		--pmic_config $(strip $(12)) \
		--pmc_config $(strip $(13)) \
		--deviceprod_config $(strip $(14)) \
		--prod_config $(strip $(15)) \
		--scr_config $(strip $(16)) \
		--wb0sdram_config $(strip $(17)) \
		--br_cmd_config $(strip $(18)) \
		--uphy $(strip $(19)) \
		--dev_params $(strip $(20)),$(strip $(21)) \
		--mb2bct_cfg $(strip $(22)) \
		--sdram_config $(strip $(23)) \
		--bins "bpmp_fw_dtb bpmp_t234-prod.bin"
	@mv $(strip $(1))/signed/* $(strip $(1))/
endef

# $1 Intermediates path
# $2 Bpmp dtb sku
# $3 Kernel dtb sku
# $4 Sdram sku
define p3710_bl_signing_rule
$(call t234_bl_signing_rule, \
  $(strip $1), \
  flash_android_t234_sdmmc.xml, \
  TE990M-A1, \
  tegra234-bpmp-3701-$(strip $2)-3737-0000.dtb, \
  tegra234-p3701-$(strip $3)-p3737-0000.dtb, \
  gbe-uphy-config-22 hsstp-lane-map-3 nvhs-uphy-config-0 hsio-uphy-config-0 gbe0-enable-10g, \
  tegra234-p3737-overlay.dtbo tegra234-p3701-overlay.dtbo, \
  tegra234-mb1-bct-device-p3701-0000.dts, \
  tegra234-mb1-bct-misc-p3701-0000.dts, \
  tegra234-mb1-bct-pinmux-p3701-0000-a04.dtsi, \
  tegra234-mb1-bct-gpioint-p3701-0000.dts, \
  tegra234-mb1-bct-pmic-p3701-0000.dts, \
  tegra234-mb1-bct-padvoltage-p3701-0000-a04.dtsi, \
  tegra234-mb1-bct-cprod-p3701-0000.dts, \
  tegra234-mb1-bct-prod-p3701-0000.dts, \
  tegra234-mb2-bct-scr-p3701-0000.dts, \
  tegra234-p3701-$(strip $4)-wb0sdram-l4t.dts, \
  tegra234-mb1-bct-reset-p3701-0000.dts, \
  tegra234-mb1-bct-uphylane-si.dtsi, \
  tegra234-br-bct-p3701-0000.dts, \
  tegra234-br-bct_b-p3701-0000.dts, \
  tegra234-mb2-bct-misc-p3701-0000.dts, \
  tegra234-p3701-$(strip $4)-sdram-l4t.dts, \
  3701, \
  $(strip $2), \
  3737, \
  0 \
)
endef

# $1 Intermediates path
# $2 Partition xml variant
# $3 Bpmp fw variant
# $4 Bpmp dtb sku
# $5 Kernel dtb sku
# $6 Sdram sku
# $7 Module sku
define p3766_bl_signing_rule
$(call t234_bl_signing_rule, \
  $(strip $1), \
  flash_android_t234_qspi_$(strip $2).xml, \
  $(strip $3), \
  tegra234-bpmp-3767-$(strip $4)-3509-a02.dtb, \
  tegra234-p3767-$(strip $5)-p3768-0000-a0-android.dtb, \
  gbe-uphy-config-8 hsstp-lane-map-3 hsio-uphy-config-0, \
  tegra234-p3767-overlay.dtbo, \
  tegra234-mb1-bct-device-p3767-0000.dts, \
  tegra234-mb1-bct-misc-p3767-0000.dts, \
  tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi, \
  tegra234-mb1-bct-gpioint-p3767-0000.dts, \
  tegra234-mb1-bct-pmic-p3767-0000-a02.dts, \
  tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi, \
  tegra234-mb1-bct-cprod-p3767-0000.dts, \
  tegra234-mb1-bct-prod-p3767-0000.dts, \
  tegra234-mb2-bct-scr-p3767-0000.dts, \
  tegra234-p3767-$(strip $6)-wb0sdram-l4t.dts, \
  tegra234-mb1-bct-reset-p3767-0000.dts, \
  tegra234-mb1-bct-uphylane-si.dtsi, \
  tegra234-br-bct-p3767-0000-l4t.dts, \
  tegra234-br-bct_b-p3767-0000-l4t.dts, \
  tegra234-mb2-bct-misc-p3767-0000.dts, \
  tegra234-p3767-$(strip $6)-sdram-l4t.dts, \
  3767, \
  $(strip $7), \
  3768, \
  0 \
)
endef

$(eval $(call p3710_bl_signing_rule, $(P3710-0000_SIGNED_PATH), 0000, 0000, 0000))
$(eval $(call p3710_bl_signing_rule, $(P3710-0004_SIGNED_PATH), 0004, 0004, 0000))
$(eval $(call p3710_bl_signing_rule, $(P3710-0005_SIGNED_PATH), 0005, 0000, 0005))

$(eval $(call p3766_bl_signing_rule, $(P3766-0000_SIGNED_PATH), nvme, TE990M-A1, 0000-a02, 0000, 0000, 0000))
$(eval $(call p3766_bl_signing_rule, $(P3766-0001_SIGNED_PATH), nvme, TE990M-A1, 0001,     0001, 0001, 0001))
$(eval $(call p3766_bl_signing_rule, $(P3766-0002_SIGNED_PATH), sd,   TE990M-A1, 0000-a02, 0000, 0000, 0002))
$(eval $(call p3766_bl_signing_rule, $(P3766-0003_SIGNED_PATH), nvme, TE950M-A1, 0003,     0003, 0001, 0003))
$(eval $(call p3766_bl_signing_rule, $(P3766-0004_SIGNED_PATH), nvme, TE950M-A1, 0004,     0004, 0004, 0004))
$(eval $(call p3766_bl_signing_rule, $(P3766-0005_SIGNED_PATH), sd,   TE950M-A1, 0003,     0003, 0001, 0005))

$(_concord_blob): $(_p3710-0000_br_bct) $(_p3710-0004_br_bct) $(_p3710-0005_br_bct) $(_p3766-0000_br_bct) $(_p3766-0001_br_bct) $(_p3766-0002_br_bct) $(_p3766-0003_br_bct) $(_p3766-0004_br_bct) $(_p3766-0005_br_bct)
	@mkdir -p $(dir $@)
	OUT=$(dir $@) TOP=$(BUILD_TOP) python2 $(TEGRAFLASH_PATH)/BUP_generator.py -t update -e \
		"$(P3710-0000_SIGNED_PATH)/psc_bl1_t234_prod_aligned_sigheader.bin.encrypt psc_bl1 3531 2 common; \
		 $(P3710-0000_SIGNED_PATH)/nvdec_t234_prod_sigheader.fw.encrypt nvdec 3531 2 common; \
		 $(P3710-0000_SIGNED_PATH)/pscfw_t234_prod_sigheader.bin.encrypt psc-fw 3531 2 common; \
		 $(P3710-0000_SIGNED_PATH)/mce_flash_o10_cr_prod_sigheader.bin.encrypt mts-mce 3531 2 common; \
		 $(P3710-0000_SIGNED_PATH)/sc7_t234_prod_sigheader.bin.encrypt sc7 3531 2 common; \
		 $(P3710-0000_SIGNED_PATH)/psc_rf_t234_prod_sigheader.bin.encrypt pscrf 3531 2 common; \
		 $(P3710-0000_SIGNED_PATH)/mb2rf_t234_sigheader.bin.encrypt mb2rf 3531 0 common; \
		 $(P3710-0000_SIGNED_PATH)/tos-optee_t234_sigheader.img.encrypt secure-os 3531 0 common; \
		 $(P3710-0000_SIGNED_PATH)/spe_t234_sigheader.bin.encrypt spe-fw 3531 0 common; \
		 $(P3710-0000_SIGNED_PATH)/camera-rtcpu-t234-rce_sigheader.img.encrypt rce-fw 3531 0 common; \
		 $(P3710-0000_SIGNED_PATH)/adsp-fw_sigheader.bin.encrypt adsp-fw 3531 0 common; \
		 $(P3710-0000_SIGNED_PATH)/xusb_t234_prod_sigheader.bin.encrypt xusb-fw 3531 2 common; \
		 $(P3710-0000_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/display-t234-dce_with_tegra234-p3701-0000-p3737-0000_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3701-0000+p3737-0000.android; \
		 $(P3710-0000_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3701-0000+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/display-t234-dce_with_tegra234-p3701-0004-p3737-0000_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3701-0004+p3737-0000.android; \
		 $(P3710-0004_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3701-0004+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/display-t234-dce_with_tegra234-p3701-0000-p3737-0000_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3701-0005+p3737-0000.android; \
		 $(P3710-0005_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3701-0005+p3737-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/display-t234-dce_with_tegra234-p3767-0000-p3768-0000-a0-android_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3767-0000+p3768-0000.android; \
		 $(P3766-0000_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3767-0000+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/display-t234-dce_with_tegra234-p3767-0001-p3768-0000-a0-android_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3767-0001+p3768-0000.android; \
		 $(P3766-0001_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3767-0001+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/display-t234-dce_with_tegra234-p3767-0000-p3768-0000-a0-android_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3767-0002+p3768-0000.android; \
		 $(P3766-0002_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3767-0002+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/display-t234-dce_with_tegra234-p3767-0003-p3768-0000-a0-android_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3767-0003+p3768-0000.android; \
		 $(P3766-0003_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3767-0003+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/display-t234-dce_with_tegra234-p3767-0004-p3768-0000-a0-android_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3767-0004+p3768-0000.android; \
		 $(P3766-0004_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3767-0004+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/mb1_t234_prod_aligned_sigheader.bin.encrypt mb1 3531 2 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/mb1_cold_boot_bct_MB1_sigheader.bct.encrypt MB1_BCT 20 0 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/mem_coldboot_sigheader.bct.encrypt MEM_BCT 20 0 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/mb2_t234_with_mb2_cold_boot_bct_MB2_sigheader.bin.encrypt mb2 3531 0 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/bpmp_t234-prod_sigheader.bin.encrypt bpmp-fw 3531 2 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/tegra234-bpmp_sigheader.dtb.encrypt bpmp-fw-dtb 3531 0 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/uefi_jetson_with_dtb_sigheader.bin.encrypt cpu-bootloader 20 0 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/display-t234-dce_with_tegra234-p3767-0003-p3768-0000-a0-android_with_odm_overlay_aligned_blob_w_bin_sigheader.bin.encrypt dce-fw 3531 0 p3767-0005+p3768-0000.android; \
		 $(P3766-0005_SIGNED_PATH)/qspi_bootblob_ver.txt VER 20 0 p3767-0005+p3768-0000.android"
	PYTHONPATH=$$PYTHONPATH:$(dir $(CAPSULE_PATH)) python3 $(CAPSULE_PATH)/GenerateCapsule.py -v --encode --monotonic-count 1 --fw-version "0x00000000" --lsv "0x00000000" --guid "bf0d4599-20d4-414e-b2c5-3595b1cda402" --signer-private-cert "$(CAPSULE_PRIVATE)" --other-public-cert "$(CAPSULE_OTHER)" --trusted-public-cert "$(CAPSULE_TRUSTED)" -o "$@" "$(dir $@)/ota.blob"

include $(BUILD_SYSTEM)/base_rules.mk

include $(CLEAR_VARS)
LOCAL_MODULE               := kernel_only_payload
LOCAL_MODULE_CLASS         := ETC
LOCAL_MODULE_RELATIVE_PATH := firmware

_kernel_blob_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_kernel_blob := $(_kernel_blob_intermediates)/$(LOCAL_MODULE)

$(_kernel_blob): $(INSTALLED_KERNEL_TARGET)
	@mkdir -p $(dir $@)
	OUT=$(dir $@) TOP=$(BUILD_TOP) python2 $(TEGRAFLASH_PATH)/BUP_generator.py -t update -e \
		"$(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb kernel-dtb 20 0 p3710-0000+p3737-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3701-0004-p3737-0000.dtb kernel-dtb 20 0 p3710-0004+p3737-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3701-0000-p3737-0000.dtb kernel-dtb 20 0 p3710-0005+p3737-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0000-p3768-0000-a0-android.dtb kernel-dtb 20 0 p3767-0000+p3768-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0001-p3768-0000-a0-android.dtb kernel-dtb 20 0 p3767-0001+p3768-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0000-p3768-0000-a0-android.dtb kernel-dtb 20 0 p3767-0002+p3768-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0003-p3768-0000-a0-android.dtb kernel-dtb 20 0 p3767-0003+p3768-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0004-p3768-0000-a0-android.dtb kernel-dtb 20 0 p3767-0004+p3768-0000.android; \
		 $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia/tegra234-p3767-0003-p3768-0000-a0-android.dtb kernel-dtb 20 0 p3767-0005+p3768-0000.android"
	@mv $(dir $@)/ota.blob $@

include $(BUILD_SYSTEM)/base_rules.mk
