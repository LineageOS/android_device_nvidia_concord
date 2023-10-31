LOCAL_PATH:= $(call my-dir)

# Parameters
# $1 Variant name
define initfiles_rule
include $(CLEAR_VARS)
LOCAL_MODULE           := fstab.$(strip $(1))
LOCAL_MODULE_CLASS     := ETC
LOCAL_SRC_FILES        := fstab.concord
LOCAL_VENDOR_MODULE    := true
LOCAL_REQUIRED_MODULES := fstab.$(strip $(1))_ramdisk
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := fstab.$(strip $(1))_ramdisk
LOCAL_MODULE_STEM   := fstab.$(strip $(1))
LOCAL_MODULE_CLASS  := ETC
LOCAL_SRC_FILES     := fstab.concord
LOCAL_MODULE_PATH   := $(TARGET_RAMDISK_OUT)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := init.$(strip $(1)).rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := init.concord.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.recovery.$(strip $(1)).rc
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := init.recovery.concord.rc
LOCAL_MODULE_PATH  := $(TARGET_ROOT_OUT)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := power.$(strip $(1)).rc
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := power.concord.rc
include $(BUILD_PREBUILT)
endef
$(foreach model,$(TARGET_TEGRA_MODELS),$(eval $(call initfiles_rule,$(model))))

include $(CLEAR_VARS)
LOCAL_MODULE               := init.concord_common.rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := init.concord_common.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.recovery.lkm.rc
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := init.recovery.lkm.rc
LOCAL_MODULE_PATH  := $(TARGET_ROOT_OUT)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := lkm_loader_target
LOCAL_SRC_FILES     := lkm_loader_target.sh
LOCAL_MODULE_SUFFIX := .sh
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)
