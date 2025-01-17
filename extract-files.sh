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

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_FIRMWARE=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-firmware )
                ONLY_FIRMWARE=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/bin/hw/vendor.qti.hardware.vibrator.service | vendor/lib64/vendor.qti.hardware.vibrator.impl.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "android.hardware.vibrator-V1-ndk_platform.so" "android.hardware.vibrator-V2-ndk.so" "${2}"
            ;;
        vendor/etc/init/netmgrd.rc)
            [ "$2" = "" ] && return 0
            sed -i "/modprobe/d" "${2}"
            ;;
        vendor/lib64/hw/fingerprint.lahaina.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --set-soname "fingerprint.lahaina.so" "${2}"
            ;;
        vendor/etc/media_codecs.xml|vendor/etc/media_codecs_yupik_v0.xml|vendor/etc/media_codecs_yupik_v1.xml)
            [ "$2" = "" ] && return 0
            sed -Ei "/media_codecs_(google_audio|google_c2|google_telephony|vendor_audio)/d" "${2}"
            ;;
        vendor/etc/seccomp_policy/atfwd@2.0.policy)
            [ "$2" = "" ] && return 0
            grep -q "gettid: 1" "${2}" || echo "gettid: 1" >> "${2}"
            ;;
        vendor/etc/media_codecs.xml|vendor/etc/media_codecs_yupik_v0.xml|vendor/etc/media_codecs_yupik_v1.xml)
            [ "$2" = "" ] && return 0
            sed -Ei "/media_codecs_(google_audio|google_telephony|vendor_audio)/d" "${2}"
            ;;
        vendor/lib64/libgf_hal.so)
            [ "$2" = "" ] && return 0
            sed -i "s/ro.boot.flash.locked/vendor.goodix.locked/g" "${2}"
            ;;
        vendor/lib64/hw/com.qti.chi.override.so)
            [ "$2" = "" ] && return 0
            grep -q libcamera_metadata_shim.so "${2}" || "${PATCHELF}" --add-needed libcamera_metadata_shim.so "${2}"
            ;;
	vendor/etc/media_codecs.xml|vendor/etc/media_codecs_lahaina.xml|vendor/etc/media_codecs_lahaina_vendor.xml|vendor/etc/media_codecs_yupik_v1.xml)
            [ "$2" = "" ] && return 0
            sed -Ei "/media_codecs_(google_audio|google_telephony|vendor_audio)/d" "${2}"
            ;;
        vendor/lib64/mediadrm/libwvdrmengine.so|vendor/lib64/libwvhidl.so)
            [ "$2" = "" ] && return 0
            grep -q "libcrypto-v33.so" "${2}" || "${PATCHELF}" --replace-needed "libcrypto.so" "libcrypto-v33.so" "$2"
            ;;

        *)
            return 1
            ;;
    esac
    return 0
}
function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper.
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

if [ -z "${ONLY_FIRMWARE}" ]; then
   extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ "${ONLY_FIRMWARE}" ]; then
   extract_firmware "${MY_DIR}/proprietary-firmware.txt" "${SRC}"
fi

"${MY_DIR}/setup-makefiles.sh"
