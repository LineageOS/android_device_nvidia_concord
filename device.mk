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

TARGET_TEGRA_KERNEL   ?= 5.10

include device/nvidia/t234-common/t234.mk

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
    power.arvala.rc \
    power.concord.rc

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml

# ATV specific stuff
ifeq ($(PRODUCT_IS_ATV),true)
    $(call inherit-product-if-exists, vendor/google/atv/atv-common.mk)

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

# Kernel
ifneq ($(TARGET_PREBUILT_KERNEL),)
TARGET_FORCE_PREBUILT_KERNEL := true
else
PRODUCT_PACKAGES += \
    nvidia-display
endif

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

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-service-nvidia \
    thermalhal.fett.xml \
    thermalhal.kryze.xml \
    thermalhal.rau.xml \
    thermalhal.saxon.xml \
    thermalhal.vizla.xml \
    thermalhal.wren.xml
