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
TARGET_MODULE_ID=3767;
TARGET_CARRIER_ID=3768;

source $(pwd)/scripts/helpers.sh;

declare -a FLASH_CMD_EEPROM=(
  --applet mb1_t234_prod.bin
  --chip 0x23
  --dev_params tegra234-br-bct-diag-boot.dts
  --device_config tegra234-mb1-bct-device-p3767-0000.dts
  --misc_config tegra234-mb1-bct-misc-p3767-0000.dts
  --cfg readinfo_t234_min_prod.xml
  --bins "mb2_applet applet_t234.bin");

if ! get_interfaces; then
  exit -1;
fi;

if ! check_compatibility ${TARGET_MODULE_ID} ${TARGET_CARRIER_ID}; then
  echo "No Jetson Orin Nano/NX Devkit found";
  exit -1;
fi;

ARVALASKU=;
SDRAMSKU=;
BPMPVAR=;
FLASH_XML=;
# 16GB NX Prod
if   [ ${MODULEINFO[sku]} -eq 0 ]; then
ARVALASKU="0000";
SDRAMSKU="0000";
BPMPVAR="TE990M";
FLASH_XML="flash_android_t234_qspi_nvme.xml";
# 8GB NX Prod
elif [ ${MODULEINFO[sku]} -eq 1 ]; then
ARVALASKU="0001";
SDRAMSKU="0001";
BPMPVAR="TE990M";
FLASH_XML="flash_android_t234_qspi_nvme.xml";
# 16GB NX Dev
elif [ ${MODULEINFO[sku]} -eq 2 ]; then
ARVALASKU="0000";
SDRAMSKU="0000";
BPMPVAR="TE990M";
FLASH_XML="flash_android_t234_qspi_sd.xml";
# 8GB Nano Prod
elif [ ${MODULEINFO[sku]} -eq 3 ]; then
ARVALASKU="0003";
SDRAMSKU="0001";
BPMPVAR="TE950M";
FLASH_XML="flash_android_t234_qspi_nvme.xml";
# 4GB Nano Prod
elif [ ${MODULEINFO[sku]} -eq 4 ]; then
ARVALASKU="0004";
SDRAMSKU="0004";
BPMPVAR="TE950M";
FLASH_XML="flash_android_t234_qspi_nvme.xml";
# 8GB Nano Dev
elif [ ${MODULEINFO[sku]} -eq 5 ]; then
ARVALASKU="0003";
SDRAMSKU="0001";
BPMPVAR="TE950M";
FLASH_XML="flash_android_t234_qspi_sd.xml";
fi;

cp tegra234-p3767-${ARVALASKU}-p3768-0000-a0-android.dtb tegra234-p3767-p3768.dtb;
cp bpmp_t234-${BPMPVAR}-A1_prod.bin bpmp_t234-prod.bin;
cp tegra234-bpmp-3767-${ARVALASKU}-3509-a02.dtb tegra234-bpmp.dtb;

# Generate version partition
if ! generate_version_bootblob_v4 qspi_bootblob_ver.txt REPLACEME; then
  echo "Failed to generate version bootblob";
  return -1;
fi;

# Add tnspec to Android Overlay
# Orin NX cannot read carrier info in rcm, thus carrier id and sku are hardcoded
CARRIERINFO[boardid]=${TARGET_CARRIER_ID};
CARRIERINFO[sku]=0;
cp AndroidConfiguration.dtbo AndroidConfig.dtbo;
if ! generate_tnspec_dtbo AndroidConfig.dtbo; then
  echo "Failed to generate tnspec";
  return -1;
fi;

declare -a FLASH_CMD_FLASH=(
  --bl uefi_jetson_with_dtb.bin
  --odmdata gbe-uphy-config-8,hsstp-lane-map-3,hsio-uphy-config-0
  --overlay_dtb AndroidConfig.dtbo,tegra234-p3767-overlay.dtbo
  --bldtb tegra234-p3767-p3768.dtb
  --applet mb1_t234_prod.bin
  --chip 0x23
  --concat_cpubl_bldtb
  --cpubl uefi_jetson.bin
  --device_config tegra234-mb1-bct-device-p3767-0000.dts
  --misc_config tegra234-mb1-bct-misc-p3767-0000.dts
  --pinmux_config tegra234-mb1-bct-pinmux-p3767-dp-a03.dtsi
  --gpioint_config tegra234-mb1-bct-gpioint-p3767-0000.dts
  --pmic_config tegra234-mb1-bct-pmic-p3767-0000-a02.dts
  --pmc_config tegra234-mb1-bct-padvoltage-p3767-dp-a03.dtsi
  --deviceprod_config tegra234-mb1-bct-cprod-p3767-0000.dts
  --prod_config tegra234-mb1-bct-prod-p3767-0000.dts
  --scr_config tegra234-mb2-bct-scr-p3767-0000.dts
  --wb0sdram_config tegra234-p3767-${SDRAMSKU}-wb0sdram-l4t.dts
  --br_cmd_config tegra234-mb1-bct-reset-p3767-0000.dts
  --uphy tegra234-mb1-bct-uphylane-si.dtsi
  --dev_params tegra234-br-bct-p3767-0000-l4t.dts,tegra234-br-bct_b-p3767-0000-l4t.dts
  --mb2bct_cfg tegra234-mb2-bct-misc-p3767-0000.dts
  --sdram_config tegra234-p3767-${SDRAMSKU}-sdram-l4t.dts
  --secondary_gpt_backup
  --bct_backup
  --boot_chain A
  --bins "psc_fw pscfw_t234_prod.bin; mts_mce mce_flash_o10_cr_prod.bin; mb2_applet applet_t234.bin; mb2_bootloader mb2_t234.bin; xusb_fw xusb_t234_prod.bin; dce_fw display-t234-dce.bin; nvdec nvdec_t234_prod.fw; bpmp_fw bpmp_t234-prod.bin; bpmp_fw_dtb tegra234-bpmp.dtb; rce_fw camera-rtcpu-t234-rce.img; ape_fw adsp-fw.bin; spe_fw spe_t234.bin; tos tos-optee_t234.img; eks eks.img");

tegraflash.py \
  "${FLASH_CMD_FLASH[@]}" \
  --instance ${INTERFACE} \
  --cfg ${FLASH_XML} \
  --cmd "flash; reboot";

rm -f tegra234-p3767-p3768.dtb bpmp_t234-prod.bin tegra234-bpmp-3767-3509.dtb qspi_bootblob_ver.txt AndroidConfig.dtbo;
