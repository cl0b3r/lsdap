#!/bin/bash

# ROOT CHECK
    whoami=$(whoami)
    if [ "$whoami" != "root" ]; then
        echo "This script must be run as root. Please use sudo."
        echo ""
        exit
    fi
#-------------------------------------------------------

# COLORS
    greenColour="\e[0;32m\033[1m"
    endColour="\033[0m\e[0m"
    redColour="\e[0;31m\033[1m"
    blueColour="\e[0;34m\033[1m"
    yellowColour="\e[0;33m\033[1m"
    purpleColour="\e[0;35m\033[1m"
    turquoiseColour="\e[0;36m\033[1m"
    grayColour="\e[0;37m\033[1m"
#---------------------------------------

# VARS
    lsdapdir="/usr/local/share/lsdap"
    localbins="./bins"
    lsdapbins="$lsdapdir/bins"
    lsdapdata="$lsdapdir/data.conf"
    lsdapfile="$lsdapdir/file.ldif"
#--------------------------------------

# help
help() {
    echo -e "Usage: lsdap [option] [arguments]
     Options:
      -ls  [object]         List objects in LDAP domain. Object is optional.
      -new [object] [name]  Create a new object in LDAP domain. 
      -mv  [object] [name]  Move an object to another location in LDAP domain.
      -rm  [object] [name]  Delete an object from LDAP domain. 
      -ssh [user@host]      Configure SSH access for a user in LDAP domain.
      -ad  [host]           Configure AnyDesk access for a user in LDAP domain.
      -menu                 Use lsdap menu tools.
      -uninstall            Uninstall the LDAP domain and all its data.
      -h                    Display this help message.

Object can be 'ou', 'user' or 'group'.
Name, username and host are always required.
Repository link if you need more information: https://github.com/cl0b3r/lsdap"
}
invalidoption() {
    echo "Invalid option, use -h for help."
}

arraypar=$(awk '{$1=""; print $0}' <<< "$*")
arraypar=$(echo $arraypar)
comprobar2=$(echo $2 | grep "-")
comprobar3=$(echo $3 | grep "-")


if [[ $# -gt 3 ]]; then
    invalidoption
elif [[ "$comprobar2" != "" ]]; then
    invalidoption
elif [[ "$comprobar3" != "" ]]; then
    invalidoption
elif [[ "$1" = "-ls" ]]; then
    bash $lsdapbins/lsdapget.sh $arraypar
elif [[ "$1" = "-new" ]]; then
    bash $lsdapbins/lsdapnew.sh $arraypar
elif [[ "$1" = "-mv" ]]; then
    bash $lsdapbins/lsdapmove.sh $arraypar
elif [[ "$1" = "-menu" ]]; then
    bash $lsdapbins/menu.sh $arraypar
elif [[ "$1" = "-rm" ]]; then
    bash $lsdapbins/lsdapdel.sh $arraypar
elif [[ "$1" = "-uninstall" ]]; then
    bash $lsdapbins/lsdapuninstall.sh $arraypar
elif [[ "$1" = "-ssh" ]]; then
    bash $lsdapbins/ssh.sh $arraypar
elif [[ "$1" = "-ad" ]]; then
    bash $lsdapbins/anydesk.sh $arraypar
elif [[ "$1" = "-h" ]]; then
    help
else
    echo "Invalid option, use -h for help."
fi