#!/bin/bash

# ROOT CHECK
    whoami=$(whoami)
    if [ "$whoami" != "root" ]; then
        echo "This script must be run as root. Please use sudo."
        echo ""
        exit
    fi

# VARS
    lsdapdir="/usr/local/share/lsdap"
    localbins="./bins"
    lsdapbins="$lsdapdir/bins"
    lsdapdata="$lsdapdir/data.conf"
    lsdapfile="$lsdapdir/file.ldif"
#--------------------------------------

if [ "$(git fetch && git status -uno | grep "up to date" | awk '{print $4}')" = "up" ]; then
    echo "Already up to date"
    exit
else
    echo "Updating..."
    git pull

    mkdir /tmp/lsdapupdate
    cp $lsdapdata /tmp/lsdapupdate/

    rm -rf $lsdapdir

    mkdir $lsdapdir
    mkdir -p $lsdapbins
    touch $lsdapfile
    cp -r $localbins/* $lsdapbins/
    cp -r /tmp/lsdapupdate/* $lsdapdir/
    rm -rf /tmp/lsdapupdate

fi