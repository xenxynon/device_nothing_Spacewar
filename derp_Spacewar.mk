# Copyright (C) 2022 PixysOS
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

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from Spacewar device
$(call inherit-product, device/nothing/Spacewar/device.mk)

# Inherit some common ROM vendor config
$(call inherit-product, vendor/derp/config/common_full_phone.mk)
TARGET_SUPPORTS_64_BIT_APPS := true
TARGET_BOOT_ANIMATION_RES := 1080

# Derp Flags
TARGET_SUPPORTS_QUICK_TAP := true
EXTRA_UDFPS_ICONS := true
TARGET_NOT_USES_BLUR := true
TARGET_USES_NOTHING_CAMERA := true

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := derp_Spacewar
PRODUCT_DEVICE := Spacewar
PRODUCT_BRAND := Nothing
PRODUCT_MODEL := A063
PRODUCT_MANUFACTURER := Nothing
PRODUCT_SYSTEM_NAME := Spacewar
PRODUCT_SYSTEM_DEVICE := Spacewar
PRODUCT_CHARACTERISTICS := nosdcard

PRODUCT_GMS_CLIENTID_BASE := android-nothing

# Override device name
PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceName=Spacewar \
