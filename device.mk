#
# Copyright (C) 2022 The LineageOS Project
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

# Only include Shield apps for first party targets
ifneq ($(filter $(word 2,$(subst _, ,$(TARGET_PRODUCT))), concord concord_tab),)
include device/nvidia/shield-common/shield.mk
endif

TARGET_REFERENCE_DEVICE ?= concord
TARGET_TEGRA_VARIANT    ?= common

TARGET_TEGRA_MODELS := $(shell awk -F, '/tegra_init::devices/{ f = 1; next } /};/{ f = 0 } f{ gsub(/"/, "", $$3); gsub(/ /, "", $$3); print $$3 }' device/nvidia/$(TARGET_REFERENCE_DEVICE)/init/init_$(TARGET_REFERENCE_DEVICE).cpp |sort |uniq)
TARGET_TEGRA_VARIANTS := $(shell awk -F, '/tegra_init::devices/{ f = 1; next } /};/{ f = 0 } f{ gsub(/"/, "", $$2); gsub(/ /, "", $$2); print $$2 }' device/nvidia/$(TARGET_REFERENCE_DEVICE)/init/init_$(TARGET_REFERENCE_DEVICE).cpp |sort |uniq)

TARGET_KERNEL_VERSION ?= 6.12
TARGET_BOOT_HAL       ?= smd
TARGET_LIGHT_HAL      ?= tegra
TARGET_SECURITY_KEYMINT_HAL ?= optee
TARGET_SUPPORTS_HARDWARE_BACKED_SECURITY ?= true
TARGET_THERMAL_HAL    ?= tegra

TARGET_HAS_BATTERY    ?= false

TARGET_TEGRA_EDK2     := lineage

include device/nvidia/t234-common/t234.mk

# System properties
include device/nvidia/concord/system_prop.mk

PRODUCT_CHARACTERISTICS   := tv
PRODUCT_AAPT_PREBUILT_DPI := xxhdpi xhdpi hdpi mdpi hdpi tvdpi
PRODUCT_AAPT_PREF_CONFIG  := xhdpi

$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

PRODUCT_USE_DYNAMIC_PARTITIONS := true

include device/nvidia/concord/vendor/concord-vendor.mk

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += device/nvidia/concord

# Init related
PRODUCT_COPY_FILES += \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.$(model)) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_RAMDISK)/fstab.$(model)) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/init.concord.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.$(model).rc) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/init.recovery.concord.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.$(model).rc) \
    $(foreach model,$(TARGET_TEGRA_MODELS),device/nvidia/concord/initfiles/power.concord.rc:$(TARGET_COPY_OUT_ODM)/etc/power.$(model).rc) \
    device/nvidia/concord/initfiles/init.concord_common.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.concord_common.rc

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml

# Audio
ifeq ($(TARGET_AUDIO_HAL),baylibre)
PRODUCT_COPY_FILES += \
    device/nvidia/tegra-common/audio/primary_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/primary_audio_policy_configuration.xml
endif

# Fingerprint override
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildFingerprint=NVIDIA/concord/concord:11/RQ1A.210105.003/13961456_3871.0251:user/release-keys

# Loadable kernel modules
PRODUCT_PACKAGES += \
    lkm_loader
PRODUCT_COPY_FILES += \
    device/nvidia/tegra-common/initfiles/init.lkm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.lkm.rc \
    device/nvidia/concord/initfiles/lkm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/lkm.rc

# Power
ifeq ($(TARGET_POWER_HAL),perfmgr-lineage)
PRODUCT_PACKAGES += \
    powerhint.rau.json
endif

# Shipping API
PRODUCT_SHIPPING_API_LEVEL := 36

# Thermal
ifeq ($(TARGET_THERMAL_HAL),tegra)
PRODUCT_COPY_FILES += \
    $(foreach variant,$(TARGET_TEGRA_VARIANTS),device/nvidia/concord/thermal/thermalhal.$(variant).xml:$(TARGET_COPY_OUT_VENDOR)/etc/thermalhal.$(variant).xml)
endif

# Trusted firmware
ATF_PATH   ?= hardware/nvidia/t23x/arm-trusted-firmware
ATF_PARAMS ?= BRANCH_PROTECTION=3 ARM_ARCH_MINOR=3

# Updater
ifneq ($(TARGET_BOOT_HAL),)
AB_OTA_PARTITIONS += \
    boot \
    product \
    recovery \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    odm
ifeq ($(TARGET_BOOT_HAL),efi)
AB_OTA_POSTINSTALL_CONFIG += \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    RUN_POSTINSTALL_system=true \
    FILESYSTEM_TYPE_product=ext4 \
    POSTINSTALL_OPTIONAL_product=true \
    POSTINSTALL_PATH_product=bin/nv_bootloader_payload_updater-efi \
    RUN_POSTINSTALL_product=true
PRODUCT_PACKAGES += \
    nv_bootloader_payload_updater-efi.product
endif
endif
