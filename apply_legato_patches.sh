#!/bin/sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 /path/to/Legato/root/directory"
    exit 1
fi

LEGATO_ROOT=$1

apply_patch() {
    patch_file=`pwd`/$1
    patch_root=${LEGATO_ROOT}/$2
    echo "---------------------------"
    echo "Applying: ${patch_file}"
    echo "At path: ${patch_root}"
    echo "---------------------------"
    export patch_root
    export patch_file
    (cd ${patch_root} && patch -p1 < ${patch_file})
    if [ $? -ne 0 ]
    then
        echo "Failed to apply patch"
        exit 1
    fi
}

apply_patch \
    "00 - 22455 - Legato - Add mangOH Red mt7697 wifi support.patch" \
    "."
apply_patch \
    "01 - 22456 - Legato WiFi - Add support for multiple wlan interfaces.patch" \
    "modules/WiFi"
apply_patch \
    "02 - 22462 - wakaama - Continue retrying block when 408 error is received.patch" \
    "3rdParty/Lwm2mCore/wakaama"
apply_patch \
    "03 - 22463 - wakaama - Only re-authenticate before tx blk 1 of a message.patch" \
    "3rdParty/Lwm2mCore/wakaama"
apply_patch \
    "04 - 22461 - wakaama - Fix bug in ACK handling.patch" \
    "3rdParty/Lwm2mCore/wakaama"
apply_patch \
    "05 - 22460 - lwmwmcore - Only re-authenticate before tx blk 1 of a message.patch" \
    "3rdParty/Lwm2mCore"
apply_patch \
    "06 - XXXXX - Legato WiFi - Fix SSID greater than 25 bytes.patch" \
    "modules/WiFi"
apply_patch \
    "07 - XXXXX - Legato WiFi - Fix returned scan results.patch" \
    "modules/WiFi"
apply_patch \
    "08 - XXXXX - Legato WiFi - Fix blocking call waiting for connection.patch" \
    "modules/WiFi"
apply_patch \
    "09 - XXXXX - Legato AV Connector - Fix session started state on disconnect.patch" \
    "apps/platformServices/airVantageConnector"
apply_patch \
    "10 - XXXXX - Legato AV Connector - Fix unhandled update state.patch" \
    "apps/platformServices/airVantageConnector"
    
echo "==========================="
echo "All patches applied successfully"
