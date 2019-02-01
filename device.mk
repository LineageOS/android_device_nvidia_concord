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

TARGET_REFERENCE_DEVICE ?= concord
TARGET_TEGRA_VARIANT    ?= common

TARGET_TEGRA_KERNEL   ?= 5.10

include device/nvidia/t234-common/t234.mk

PRODUCT_CHARACTERISTICS   := tv
PRODUCT_AAPT_PREBUILT_DPI := xxhdpi xhdpi hdpi mdpi hdpi tvdpi
PRODUCT_AAPT_PREF_CONFIG  := xhdpi

$(call inherit-product, frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk)

PRODUCT_USE_DYNAMIC_PARTITIONS := true

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

# Kernel
ifneq ($(TARGET_PREBUILT_KERNEL),)
TARGET_FORCE_PREBUILT_KERNEL := true
else
PRODUCT_PACKAGES += \
    nvidia-display
endif

# Partitions for dynamic
PRODUCT_COPY_FILES += \
    device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_RAMDISK)/fstab.arvala \
    device/nvidia/concord/initfiles/fstab.concord:$(TARGET_COPY_OUT_RAMDISK)/fstab.concord
