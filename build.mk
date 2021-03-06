LOCAL_PATH := $(call my-dir)

name := incremental-$(INCREMENTAL_SOURCE_BUILD_ID)-$(BUILD_NUMBER).zip

INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET := $(PRODUCT_OUT)/$(name)

# NOTE: Since the following variables are only valid for the given target
# we manually need to keep them in sync with the INTERNAL_OTA_PACKAGE_TARGET
# definition in build/core/Makefile!
# BEGIN: KEEP IN SYNC WITH INTERNAL_OTA_PACKAGE_TARGET
ifeq ($(WITH_GMS),true)
    $(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET): backuptool := false
else
ifneq ($(CM_BUILD),)
    $(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET): backuptool := true
else
    $(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET): backuptool := false
endif
endif

ifeq ($(TARGET_OTA_ASSERT_DEVICE),)
    $(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET): override_device := auto
else
    $(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET): override_device := $(TARGET_OTA_ASSERT_DEVICE)
endif

ifneq ($(TARGET_UNIFIED_DEVICE),)
    $(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET): override_prop := --override_prop=true
endif
# END: KEEP IN SYNC WITH INTERNAL_OTA_PACKAGE_TARGET

ifneq ($(TARGET_INCREMENTAL_OTA_VERBATIM_FILES),)
    # This is only supported by Quarx2k/android/build, xdarklight/android_build
    # or whatever has cherry-picked:
    # https://android-review.googlesource.com/#/c/106130/1/tools/releasetools/ota_from_target_files
    verbatim_files := --verbatim_files=$(TARGET_INCREMENTAL_OTA_VERBATIM_FILES)
endif

$(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET):
	@echo -e ${CL_YLW}"Creating incremental update for CMUpdater: $@"${CL_RST}

	$(OTA_FROM_TARGET_SCRIPT) -v \
	   -p $(HOST_OUT) \
	   --backup=$(backuptool) \
	   --override_device=$(override_device) \
	   $(override_prop) \
	   $(verbatim_files) \
	   --incremental_from $(INCREMENTAL_SOURCE_TARGETFILES_ZIP) \
           $(OTA_FROM_TARGET_SCRIPT_EXTRA_OPTS) \
	   $(BUILT_TARGET_FILES_PACKAGE) $@

.PHONY: cmupdaterincremental
cmupdaterincremental: $(INTERNAL_CMUPDATER_INCREMENTAL_PACKAGE_TARGET)
