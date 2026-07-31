#
# Copyright (C) 2022-2023 The LineageOS Project
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
#

# Gpu driver
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    governor_pod_scaling \
    nvidia-drm \
    nvgpu

# Tegra-drm, for falcons such vic and nvdec
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    tegra-drm-next

# Usb Bluetooth
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    btusb

# Realtek wifi
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    rtw88_8822ce

# Stm ethernet
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    dwmac-tegra

# Tegra hdmi audio
ifeq ($(TARGET_KERNEL_VERSION),6.12)
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    snd-hda-codec-hdmi
else
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    snd-hda-codec-tegrahdmi
endif
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    snd-hda-tegra

# Audio Codecs
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    snd-soc-rt5640

# Tegra audio processing engine
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    tegra-aconnect \
    tegra210-adma \
    snd-soc-tegra210-ahub \
    snd-soc-tegra210-sfc \
    snd-soc-tegra210-i2s \
    snd-soc-tegra210-mixer \
    snd-soc-tegra210-amx \
    snd-soc-tegra210-admaif \
    snd-soc-tegra210-adx \
    snd-soc-tegra210-iqc \
    snd-soc-tegra210-afc \
    snd-soc-tegra210-dmic \
    snd-soc-tegra210-mvc \
    snd-soc-tegra210-ope \
    snd-soc-tegra186-dspk \
    snd-soc-tegra186-asrc \
    snd-soc-tegra-audio-graph-card

# Nvidia Controllers
BOARD_VENDOR_KERNEL_MODULES_LOAD += \
    hid-nvidia-shield \
    hid-nvidia-shield-oot


# Copy to boot
BOOT_KERNEL_MODULES := \
    system_heap.ko \
    qcom-scm.ko \
    qcom_tzmem.ko \
    arm_smmu.ko \
    tegra194-cpufreq.ko \
    tegra186-gpc-dma.ko \
    i2c-tegra.ko \
    i2c-tegra-bpmp.ko \
    spi-tegra114.ko \
    spi-tegra210-quad.ko \
    rtc-tegra.ko \
    nvidia-vrs-pseq.ko \
    gpio-tegra186.ko \
    phy-tegra194-p2u.ko \
    pcie-tegra194.ko \
    phy-tegra-xusb.ko \
    xhci-tegra.ko \
    tegra-xudc.ko \
    ucsi_ccg.ko \
    fusb301.ko \
    hwmon.ko \
    pwm-tegra.ko \
    pwm-fan.ko \
    pwm-tegra-tachometer.ko \
    tegra-bpmp-thermal.ko \
    cqhci.ko \
    sdhci-tegra.ko \
    host1x-next.ko \
    tegra-dce.ko \
    host1x-nvhost.ko \
    mc-utils.ko \
    tsecriscv.ko \
    drm_display_helper.ko \
    tegra_hv.ko \
    ivc_ext.ko \
    nvidia.ko \
    nvidia-modeset.ko \
    nvidia-drm.ko \
    efivarfs.ko

ifeq ($(TARGET_SECURITY_KEYMINT_HAL),trusty)
BOOT_KERNEL_MODULES += \
    ffa-core.ko \
    ffa-module.ko \
    trusty-core.ko \
    trusty-ffa.ko \
    trusty-ipc.ko \
    trusty-log.ko \
    trusty-populate.ko \
    trusty-smc.ko \
    trusty-test.ko \
    trusty-virtio.ko \
    trusty-virtio-polling.ko
else ifeq ($(TARGET_SECURITY_KEYMINT_HAL),optee)
BOOT_KERNEL_MODULES += \
    tee.ko \
    optee.ko
endif

# Load in first stage boot
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    system_heap \
    tegra194-cpufreq \
    arm_smmu \
    tegra186-gpc-dma \
    i2c-tegra \
    i2c-tegra-bpmp \
    spi-tegra114 \
    spi-tegra210-quad \
    rtc-tegra \
    nvidia-vrs-pseq \
    gpio-tegra186 \
    phy-tegra194-p2u \
    pcie-tegra194 \
    xhci-tegra \
    tegra-xudc \
    ucsi_ccg \
    fusb301 \
    pwm-tegra \
    pwm-fan \
    pwm-tegra-tachometer \
    tegra-bpmp-thermal \
    sdhci-tegra \
    efivarfs

ifeq ($(TARGET_SECURITY_KEYMINT_HAL),trusty)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD += \
    trusty-smc \
    trusty-log \
    trusty-ipc \
    trusty-virtio
else ifeq ($(TARGET_SECURITY_KEYMINT_HAL),optee)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD += \
    optee
endif


# Copy to recovery
RECOVERY_KERNEL_MODULES := \
    $(BOOT_KERNEL_MODULES) \
    hid-nvidia-shield.ko \
    hid-nvidia-shield-oot.ko

# Load in recovery
BOARD_RECOVERY_KERNEL_MODULES_LOAD := \
    $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD) \
    hid-nvidia-shield \
    hid-nvidia-shield-oot
