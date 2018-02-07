#!/bin/sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 /path/to/Legato/root/directory"
    exit 1
fi

LEGATO_ROOT=$1

if ! [ -d $LEGATO_ROOT ]
then
    echo "\"$LEGATO_ROOT\" does is not a directory"
    exit 1
fi

NOW=`date +"%Y-%m-%d_%H_%M_%S"`
PATCH_BRANCH="mangOH_patches_$NOW"
PATCH_BASE="18.01.0"

apply_patchset() {
    PATCH_SRC_DIR=`readlink -f $1`
    PATCH_DEST_DIR=$2
    echo "==========================="
    echo "Applying patches from $PATCH_SRC_DIR to $PATCH_DEST_DIR on branch $PATCH_BRANCH"
    echo "==========================="
    (cd $PATCH_DEST_DIR && git checkout -b $PATCH_BRANCH $PATCH_BASE)
    if [ $? -ne 0 ]
    then
        echo "Couldn't create branch in $PATCH_DEST_DIR"
        exit $?
    fi
    (cd $PATCH_DEST_DIR && git am $PATCH_SRC_DIR/*.patch)
    if [ $? -ne 0 ]
    then
        echo "Command failed with exit code: $?"
        exit $?
    fi
    echo "==========================="
}

apply_patchset legato       $LEGATO_ROOT
apply_patchset wifi         $LEGATO_ROOT/modules/WiFi

echo "==========================="
echo "All patches applied successfully"
