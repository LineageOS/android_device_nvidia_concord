#
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
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE       := nvpmodel_p3701_0000.conf
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := nvpmodel_p3701_0000.conf
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nvpmodel_p3701_0004.conf
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := nvpmodel_p3701_0004.conf
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nvpmodel_p3767_0000.conf
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := nvpmodel_p3767_0000.conf
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nvpmodel_p3767_0001.conf
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := nvpmodel_p3767_0001.conf
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nvpmodel_p3767_0003.conf
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := nvpmodel_p3767_0003.conf
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nvpmodel_p3767_0004.conf
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := nvpmodel_p3767_0004.conf
include $(BUILD_PREBUILT)
