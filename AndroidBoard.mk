# Copyright (C) 2023 The LineageOS Project
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

ifeq ($(TARGET_PREBUILT_KERNEL),)
recovery_uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery.cpio
INSTALLED_NVIDIA_DISPLAY_KO    := $(TARGET_OUT_VENDOR)/lib/modules/nvidia-display.ko

RECOVERY_KMOD_TARGETS := \
    hid-jarvis-remote.ko \
    hid-nvidia-blake.ko \
    nvidia.ko \
    nvidia-drm.ko \
    nvidia-modeset.ko \
    tegra-bpmp-thermal.ko \
    pwm-fan.ko
INSTALLED_RECOVERY_KMOD_TARGETS := $(RECOVERY_KMOD_TARGETS:%=$(TARGET_RECOVERY_ROOT_OUT)/lib/modules/%)
$(INSTALLED_RECOVERY_KMOD_TARGETS): $(INSTALLED_NVIDIA_DISPLAY_KO)
	echo -e ${CL_GRN}"Copying kernel modules to recovery"${CL_RST}
	@mkdir -p $(dir $@)
	cp $(@F:%=$(TARGET_OUT_VENDOR)/lib/modules/%) $(TARGET_RECOVERY_ROOT_OUT)/lib/modules/

$(recovery_uncompressed_ramdisk): $(INSTALLED_RECOVERY_KMOD_TARGETS)
endif
