# Baylibre audio
ifeq ($(TARGET_AUDIO_HAL),baylibre)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.audio.primary.device=3
endif

# AV
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.media.avsync=true

# fastbootd
PRODUCT_PROPERTY_OVERRIDES += \
    ro.fastbootd.available=true
