#!/bin/bash

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


for git_repo in `find $LEGATO_ROOT -type d -name '.git' | sed 's/\/\.git$//'`
do
    pushd $git_repo > /dev/null
    for branch in `git branch --list mangOH_patches_????-??-??_??_??_?? | cut -c 3-`
    do
        echo "--> Trying to delete: repo=$git_repo branch=$branch"
        git branch -D $branch
    done
    popd > /dev/null
done
