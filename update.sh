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
    git reset --hard origin/$(git branch --show-current)
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
    chmod 755 $lsdapbins/*
    chmod 755 update.sh
    chmod 755 set-up.sh
    usuario=$(cat /etc/passwd | grep 1000 | awk -F ':' '{print $1}')
    chown $usuario:$usuario update.sh
    chown $usuario:$usuario set-up.sh

fi