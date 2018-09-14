#!/bin/bash

# ----------------------------------------- IMPORTANT NOTE -----------------------------------------
# The regular apply_legato_patches.sh is preferred over this script, but this script must be used if
# the Legato source code to be patched is not tracked by git.
# --------------------------------------------------------------------------------------------------

if [ $# -ne 2 ]
then
    echo "Usage: $0 /path/to/Legato/root/directory release_tag"
    exit 1
fi

LEGATO_ROOT=$1
PATCH_BASE=$2

if ! [ -d $LEGATO_ROOT ]
then
    echo "\"$LEGATO_ROOT\" is not a directory"
    exit 1
fi

if ! [ -d $PATCH_BASE ]
then
    echo "No patch directory exists for \"$PATCH_BASE\""
    exit 1
fi

apply_patchset() {
    PATCH_SRC_DIR=$PATCH_BASE/$1
    PATCH_DEST_DIR=$2
    PATCH_SRC_DIR_ABS=`readlink -f $PATCH_SRC_DIR`
    if ! [ -d $PATCH_SRC_DIR_ABS ]
    then
        return
    fi

    echo "==========================="
    echo "Applying patches from $PATCH_SRC_DIR_ABS to $PATCH_DEST_DIR"
    echo "==========================="
    (cd $PATCH_DEST_DIR && for p in `ls $PATCH_SRC_DIR_ABS/*.patch`; do patch -p1 < $p; done)
    if [ $? -ne 0 ]
    then
        echo "Command failed with exit code: $?"
        exit $?
    fi
    echo "==========================="
}

apply_patchset legato       $LEGATO_ROOT
apply_patchset wifi         $LEGATO_ROOT/modules/WiFi
apply_patchset av_connector $LEGATO_ROOT/apps/platformServices/airVantageConnector
apply_patchset lwm2mcore    $LEGATO_ROOT/3rdParty/Lwm2mCore
if [[ "$PATCH_BASE" > "18.03.0" ]]
then
    apply_patchset wakaama      $LEGATO_ROOT/3rdParty/Lwm2mCore/3rdParty/wakaama
else
    apply_patchset wakaama      $LEGATO_ROOT/3rdParty/Lwm2mCore/wakaama
fi

echo "==========================="
echo "All patches applied successfully"
