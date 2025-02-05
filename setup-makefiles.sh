#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=Spacewar
VENDOR=nothing

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function vendor_imports() {
    cat <<EOF >>"$1"
		"device/nothing/Spacewar",
		"hardware/google/interfaces",
		"hardware/google/pixel",
		"hardware/lineage/interfaces/power-libperfmgr",
		"hardware/qcom-caf/bootctrl",
		"hardware/qcom-caf/common/libqti-perfd-client",
		"hardware/qcom-caf/sm8350",
		"hardware/qcom-caf/wlan",
		"vendor/qcom/opensource/commonsys/display",
		"vendor/qcom/opensource/commonsys-intf/display",
		"vendor/qcom/opensource/data-ipa-cfg-mgr-legacy-um",
		"vendor/qcom/opensource/dataservices",
		"vendor/qcom/opensource/display",
		"vendor/qcom/opensource/usb/etc",
EOF
}

function lib_to_package_fixup_vendor_variants() {
    if [ "$2" != "vendor" ]; then
        return 1
    fi

    case "$1" in
            com.qualcomm.qti.dpm.api@1.0 | \
            com.qualcomm.qti.imscmservice* | \
            com.qualcomm.qti.uceservice* | \
            libmmosal | \
            vendor.qti.data.* | \
            vendor.qti.diaghal@1.0 | \
            vendor.qti.hardware.data.* | \
            vendor.qti.hardware.embmssl* | \
            vendor.qti.hardware.mwqemadapter@1.0 | \
            vendor.qti.hardware.radio.* | \
            vendor.qti.hardware.slmadapter@1.0 | \
            vendor.qti.hardware.wifidisplaysession@1.0 | \
            vendor.qti.imsrtpservice@3.0 | \
            vendor.qti.hardware.qccvndhal@1.0 | \
            vendor.qti.ims.* | \
            vendor.qti.latency* | \
            vendor.qti.hardware.qccsyshal@1.0 | \
            vendor.qti.hardware.qccvndhal@1.0 | \
            vendor.qti.qspmhal@1.0 | \
            vendor.qti.hardware.limits@1.0 )
            echo "$1_vendor"
            ;;
        libOmxCore | \
            libwpa_client)
            # Android.mk only packages
            ;;
        *)
            return 1
            ;;
    esac
}

function lib_to_package_fixup() {
        lib_to_package_fixup_clang_rt_ubsan_standalone "$1" ||
        lib_to_package_fixup_proto_3_9_1 "$1" ||
        lib_to_package_fixup_vendor_variants "$@"
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

write_makefiles "${MY_DIR}/proprietary-files.txt"

append_firmware_calls_to_makefiles "${MY_DIR}/proprietary-firmware.txt"

# Finish
write_footers
