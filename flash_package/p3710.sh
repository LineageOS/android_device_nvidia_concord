#!/bin/bash

# Copyright (C) 2021 The LineageOS Project
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

PATH=$(pwd)/tegraflash:${PATH}

TARGET_TEGRA_VERSION=t234;
TARGET_MODULE_ID=3701;
TARGET_CARRIER_ID=3737;

source $(pwd)/scripts/helpers.sh;

declare -a FLASH_CMD_EEPROM=(
  --applet mb1_t234_prod.bin
  --chip 0x23
  --dev_params tegra234-br-bct-diag-boot.dts
  --device_config tegra234-mb1-bct-device-p3701-0000.dts
  --misc_config tegra234-mb1-bct-misc-p3701-0000.dts
  --cfg readinfo_t234_min_prod.xml
  --bins "mb2_applet applet_t234.bin");

if ! get_interfaces; then
  exit -1;
fi;

if ! check_compatibility ${TARGET_MODULE_ID} ${TARGET_CARRIER_ID}; then
  echo "No Jetson AGX Orin Devkit found";
  exit -1;
fi;

if [ ! "${MODULEINFO[chipskurev]}" == "D0" -a ! "${MODULEINFO[chipskurev]}" == "D2"  ]; then
  echo "Jetson AGX Orin module soc revision ${MODULEINFO[chipskurev]} is not supported";
fi;

BPMPSKU=;
DTBSKU=;
SDRAMSKU=;
if   [ ${MODULEINFO[sku]} -eq 0 ]; then
BPMPSKU="0000";
DTBSKU="0000";
SDRAMSKU="0000";
elif [ ${MODULEINFO[sku]} -eq 4 ]; then
BPMPSKU="0004";
DTBSKU="0004";
SDRAMSKU="0000";
elif [ ${MODULEINFO[sku]} -eq 5 ]; then
BPMPSKU="0005";
DTBSKU="0000";
SDRAMSKU="0005";
else
  echo "Unsupported AGX Orin module sku: ${MODULEINFO[sku]}";
  exit -1;
fi;

cp tegra234-p3701-${DTBSKU}-p3737-0000.dtb tegra234-p3701-p3737.dtb;
cp bpmp_t234-TE990M-A1_prod.bin bpmp_t234-prod.bin;
cp tegra234-bpmp-3701-${BPMPSKU}-3737-0000.dtb tegra234-bpmp.dtb;

# Generate version partition
if ! generate_version_bootblob_v4 qspi_bootblob_ver.txt REPLACEME; then
  echo "Failed to generate version bootblob";
  return -1;
fi;

# Add tnspec to Android Overlay
# AGX Orin cannot read carrier info in rcm, thus carrier id and sku are hardcoded
CARRIERINFO[boardid]=${TARGET_CARRIER_ID};
CARRIERINFO[sku]=0;
cp AndroidConfiguration.dtbo AndroidConfig.dtbo;
if ! generate_tnspec_dtbo AndroidConfig.dtbo; then
  echo "Failed to generate tnspec";
  return -1;
fi;

declare -a FLASH_CMD_FLASH=(
  --bl uefi_jetson_with_dtb.bin
  --odmdata gbe-uphy-config-22,hsstp-lane-map-3,nvhs-uphy-config-0,hsio-uphy-config-0,gbe0-enable-10g
  --overlay_dtb AndroidConfig.dtbo,tegra234-p3737-audio-codec-rt5658-40pin.dtbo,tegra234-p3737-overlay.dtbo,tegra234-p3701-overlay.dtbo
  --bldtb tegra234-p3701-p3737.dtb
  --applet mb1_t234_prod.bin
  --chip 0x23
  --concat_cpubl_bldtb
  --cpubl uefi_jetson.bin
  --device_config tegra234-mb1-bct-device-p3701-0000.dts
  --misc_config tegra234-mb1-bct-misc-p3701-0000.dts
  --pinmux_config tegra234-mb1-bct-pinmux-p3701-0000-a04.dtsi
  --gpioint_config tegra234-mb1-bct-gpioint-p3701-0000.dts
  --pmic_config tegra234-mb1-bct-pmic-p3701-0000.dts
  --pmc_config tegra234-mb1-bct-padvoltage-p3701-0000-a04.dtsi
  --deviceprod_config tegra234-mb1-bct-cprod-p3701-0000.dts
  --prod_config tegra234-mb1-bct-prod-p3701-0000.dts
  --scr_config tegra234-mb2-bct-scr-p3701-0000.dts
  --wb0sdram_config tegra234-p3701-${SDRAMSKU}-wb0sdram-l4t.dts
  --br_cmd_config tegra234-mb1-bct-reset-p3701-0000.dts
  --uphy tegra234-mb1-bct-uphylane-si.dtsi
  --dev_params tegra234-br-bct-p3701-0000.dts,tegra234-br-bct_b-p3701-0000.dts
  --mb2bct_cfg tegra234-mb2-bct-misc-p3701-0000.dts
  --sdram_config tegra234-p3701-${SDRAMSKU}-sdram-l4t.dts
  --secondary_gpt_backup
  --bct_backup
  --boot_chain A
  --bins "psc_fw pscfw_t234_prod.bin; mts_mce mce_flash_o10_cr_prod.bin; mb2_applet applet_t234.bin; mb2_bootloader mb2_t234.bin; xusb_fw xusb_t234_prod.bin; dce_fw display-t234-dce.bin; nvdec nvdec_t234_prod.fw; bpmp_fw bpmp_t234-prod.bin; bpmp_fw_dtb tegra234-bpmp.dtb; rce_fw camera-rtcpu-t234-rce.img; ape_fw adsp-fw.bin; spe_fw spe_t234.bin; tos tos-optee_t234.img; eks eks.img");

tegraflash.py \
  "${FLASH_CMD_FLASH[@]}" \
  --instance ${INTERFACE} \
  --cfg flash_android_t234_sdmmc.xml \
  --cmd "flash; reboot";

rm -f tegra234-p3701-p3737.dtb bpmp_t234-prod.bin tegra234-bpmp-3701-3737.dtb qspi_bootblob_ver.txt AndroidConfig.dtbo;
