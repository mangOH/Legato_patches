#!/bin/sh

if [ $# -ne 2 ]
then
    echo "Usage: $0 /path/to/Legato/root/directory release_tag"
    exit 1
fi

LEGATO_ROOT=$1
PATCH_BASE=$2

if ! [ -d $LEGATO_ROOT ]
then
    echo "\"$LEGATO_ROOT\" does is not a directory"
    exit 1
fi

(cd $LEGATO_ROOT && git rev-parse $PATCH_BASE)
if [ $? -ne 0 ]
then
    echo "\"$PATCH_BASE\" doesn't appear to be a valid release tag"
    exit 1
fi

if ! [ -d $PATCH_BASE ]
then
    echo "No patch directory exists for \"$PATCH_BASE\""
    exit 1
fi

NOW=`date +"%Y-%m-%d_%H_%M_%S"`
PATCH_BRANCH="mangOH_patches_$NOW"

apply_patchset() {
    PATCH_SRC_DIR=$PATCH_BASE/$1
    PATCH_DEST_DIR=$2
    PATCH_SRC_DIR_ABS=`readlink -f $PATCH_SRC_DIR`
    if ! [ -d $PATCH_SRC_DIR_ABS ]
    then
        return
    fi

    echo "==========================="
    echo "Applying patches from $PATCH_SRC_DIR_ABS to $PATCH_DEST_DIR on branch $PATCH_BRANCH"
    echo "==========================="
    (cd $PATCH_DEST_DIR && git checkout -b $PATCH_BRANCH $PATCH_BASE)
    if [ $? -ne 0 ]
    then
        echo "Couldn't create branch in $PATCH_DEST_DIR"
        exit $?
    fi
    (cd $PATCH_DEST_DIR && git am $PATCH_SRC_DIR_ABS/*.patch)
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
