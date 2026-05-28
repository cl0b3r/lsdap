#!/bin/bash

# ROOT CHECK
    whoami=$(whoami)
    if [ "$whoami" != "root" ]; then
        echo "This script must be run as root. Please use sudo."
        echo ""
        exit
    fi
#-------------------------------------------------------

# VARS
    lsdapdir="/usr/local/share/lsdap"
    localbins="./bins"
    lsdapbins="$lsdapdir/bins"
    lsdapdata="$lsdapdir/data.conf"
    lsdapfile="$lsdapdir/file.ldif"

    dc1=$(cat $lsdapdata | grep "fqdn" | awk -F'=' '{print $2}' | awk -F'.' '{print $2}')
    dc2=$(cat $lsdapdata | grep "fqdn" | awk -F'=' '{print $2}' | awk -F'.' '{print $3}')
    basedn="$dc1.$dc2"
    ldappassword=$(cat $lsdapdata | grep "lsdappassword" | awk -F'=' '{print $2}')

#--------------------------------------


if [ $# -ne 2 ]; then
    echo "invalid parameters. Use -h for help."
    exit 
fi


move() {
    exist=$(slapcat | grep "$2,")
    if [ "$exist" = "" ]; then
        echo "The specified object does not exist."
        exit
    fi
        if [[ $1 = "ou" ]]; then

            if [[ -z "$(slapcat -a "(&(ou=$2)(objectClass=organizationalUnit))")" ]]; then
                echo "The object $2 is not an organizational unit."
                exit
            fi
        fi 
        
        if [[ $1 = "user" ]]; then
            if [[ -z "$(slapcat -a "(&(cn=$2)(objectClass=posixAccount))")" ]]; then
                echo "The object $2 is not a user."
                exit
            fi
        fi
        
        if [[ $1 = "group" ]]; then
            if [[ -z "$(slapcat -a "(&(cn=$2)(objectClass=posixGroup))")" ]]; then
                echo "The object $2 is not a group."
                exit
            fi
        fi

    lsdap -ls
    read -p "Enter the new location for the object --> " newlocation



    origen=$(slapcat | sed -e ':a' -e 'N' -e 's/\n //; ba' | grep -E -i "^dn:[[:space:]]*(uid|cn|ou)=${2},")
    destino=$(slapcat | sed -e ':a' -e 'N' -e 's/\n //; ba' | grep -E -i "^dn:[[:space:]]*(uid|cn|ou)=${newlocation}," | awk -F' ' '{print $2}')

    origencheck=$(slapcat | sed -e ':a' -e 'N' -e 's/\n //; ba' | grep -E -i "^dn:[[:space:]]*(uid|cn|ou)=${2},")
    destinocheck=$(slapcat | sed -e ':a' -e 'N' -e 's/\n //; ba' | grep -E -i "^dn:[[:space:]]*(uid|cn|ou)=${newlocation},")

    comprarou=$(slapcat | grep "^dn: ou=$newlocation")

    if [ "$comprarou" = "" ]; then
        echo "The new location is not an OU or not exist."
        exit
    elif [ "$origencheck" = "$destinocheck" ]; then
        echo "Origin and destination canot be the same."
        exit
    elif [ "$destino" = "" ]; then
        echo "The specified new location does not exist."
        exit
    fi

    if [[ "$1" = "ou" ]]; then
        ouname=$(echo $origen | awk -F ',' '{print $1}' | awk  '{print $2}')
        newrdn="newrdn: $ouname"
    elif [[ "$1" = "user" ]]; then
        username=$(echo $origen | awk -F ',' '{print $1}' | awk  '{print $2}')
        newrdn="newrdn: $username"
    elif [[ "$1" = "group" ]]; then
        groupname=$(echo $origen | awk -F ',' '{print $1}' | awk  '{print $2}')
        newrdn="newrdn: $groupname"
    fi


    echo "$origen
changetype: modrdn
$newrdn
deleteoldrdn: 1
newsuperior: $destino" > $lsdapfile
    ldapmodify -x -D "cn=admin,dc=$dc1,dc=$dc2" -w "$ldappassword" -f $lsdapfile
}


if [[ "$1" = "ou" ]]; then
    move $1 $2
elif [[ "$1" = "user" ]]; then
    move $1 $2
elif [[ "$1" = "group" ]]; then
    move $1 $2
else 
    echo "Invalid object specified. Use -h for help."
    exit 
fi