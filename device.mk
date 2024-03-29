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

TARGET_TEGRA_BOOTCTRL ?= efi
TARGET_TEGRA_BT       ?= btlinux
TARGET_TEGRA_CAMERA   ?= rel-shield-r
TARGET_TEGRA_HEALTH   ?= nobattery
TARGET_TEGRA_KERNEL   ?= 5.10
TARGET_TEGRA_KEYSTORE ?= software
TARGET_TEGRA_WIDEVINE ?= rel-shield-r
TARGET_TEGRA_WIFI     ?= rtl8822ce

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
PRODUCT_PACKAGES += \
    fstab.arvala \
    fstab.concord \
    init.arvala.rc \
    init.concord.rc \
    init.concord_common.rc \
    init.recovery.arvala.rc \
    init.recovery.concord.rc \
    init.recovery.lkm.rc \
    power.arvala.rc \
    power.concord.rc

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml

# ATV specific stuff
ifeq ($(PRODUCT_IS_ATV),true)
    PRODUCT_PACKAGES += \
        android.hardware.tv.input@1.0-impl
endif

# Audio
ifneq ($(filter rel-shield-r, $(TARGET_TEGRA_AUDIO)),)
PRODUCT_PACKAGES += \
    audio_effects.xml \
    audio_policy_configuration.xml \
    nvaudio_conf.xml \
    nvaudio_fx.xml
endif

# fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Kernel
ifneq ($(TARGET_PREBUILT_KERNEL),)
TARGET_FORCE_PREBUILT_KERNEL := true
else
PRODUCT_PACKAGES += \
    nvidia-display
endif

# Light
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service-nvidia

# Loadable kernel modules
PRODUCT_PACKAGES += \
    init.lkm.rc \
    lkm_loader \
    lkm_loader_target

# Media config
PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_ODM)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_ODM)/etc/media_codecs_google_video.xml
PRODUCT_PACKAGES += \
    media_codecs.xml
ifneq ($(filter rel-shield-r, $(TARGET_TEGRA_OMX)),)
PRODUCT_PACKAGES += \
    media_codecs_performance.xml \
    media_profiles_V1_0.xml \
    enctune.conf
endif

# Partitions for dynamic
PRODUCT_COPY_FILES += \
    device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_RAMDISK)/fstab.arvala \
    device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_RAMDISK)/fstab.concord

# PHS
ifneq ($(TARGET_TEGRA_PHS),)
PRODUCT_PACKAGES += \
    nvphsd.conf
endif

# PModel
PRODUCT_PACKAGES += \
    nvpmodel \
    nvpmodel_p3701_0000.conf \
    nvpmodel_p3701_0004.conf \
    nvpmodel_p3767_0000.conf \
    nvpmodel_p3767_0001.conf \
    nvpmodel_p3767_0003.conf \
    nvpmodel_p3767_0004.conf

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-service-nvidia \
    thermalhal.fett.xml \
    thermalhal.kryze.xml \
    thermalhal.rau.xml \
    thermalhal.saxon.xml \
    thermalhal.vizla.xml \
    thermalhal.wren.xml

# Updater
ifneq ($(TARGET_TEGRA_BOOTCTRL),)
AB_OTA_PARTITIONS += \
    boot \
    product \
    recovery \
    system \
    vbmeta \
    vbmeta_system \
    vendor \
    odm
ifeq ($(TARGET_PREBUILT_KERNEL),)
ifeq ($(TARGET_TEGRA_BOOTCTRL),efi)
AB_OTA_POSTINSTALL_CONFIG += \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true \
    POSTINSTALL_PATH_system=system/bin/nv_bootloader_payload_updater \
    RUN_POSTINSTALL_system=true
PRODUCT_PACKAGES += \
    nv_bootloader_payload_updater \
    kernel_only_payload \
    AndroidLauncher \
    TEGRA_BL.Cap
endif
endif
endif
