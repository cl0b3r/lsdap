#!/bin/bash

#si el usuario no es root, muestra un error y sale con 2
if [ $(id -u) -ne 0 ]; then
	echo "del-ldap: Permission denied."
	exit 2
fi

if [ $# -gt 2 ]; then
	echo "del-ldap: Numbers of params incorrect."
	exit 2
fi

# VARS
	lsdapdir="/usr/local/share/lsdap"
	localbins="./bins"
	lsdapbins="$lsdapdir/bins"
	lsdapdata="$lsdapdir/data.conf"
	lsdapfile="$lsdapdir/file.ldif"

	dominio=$(slapcat | grep "^dn: dc=" | grep -v "nodomain" | sed 's/dn: //g')
	admin="cn=admin,$dominio"
	ldappassword=$(cat "$lsdapdata" | grep "lsdappassword" | awk -F'=' '{print $2}')

if [ "$1" = "user" ]; then
	deleteuser $2
elif [ "$1" = "ou" ]; then
	deleteou $2
elif [ "$1" = "group" ]; then
	deletegroup $2
else 
	echo "Object '$1' not valid. Object should be 'ou', 'group' or 'user'. Use -h for help."
	exit 2
fi

deleteuser() {
	dn_objeto=$(slapcat | grep -i "^dn: cn=$1," | sed 's/dn: //g')
	if [ -z "$dn_objeto" ]; then
        echo "Error: El usuario '$1' no existe en LDAP."
        exit 
    fi
	echo "ldapdelete -x -D "$admin" -w "$ldappassword" "$dn_objeto""
	exit
}

deleteou() {
	dn_objeto=$(slapcat | grep -i "^dn: ou=$1," | sed 's/dn: //g')
	if [ -z "$dn_objeto" ]; then
        echo "Error: La unidad organizativa '$1' no existe en LDAP."
        exit 
    fi
	echo "ldapdelete -x -D "$admin" -w "$ldappassword" "$dn_objeto""
}

deletegroup() {
	dn_objeto=$(slapcat | grep -i "^dn: cn=$1," | sed 's/dn: //g')
	if [ -z "$dn_objeto" ]; then
        echo "Error: El grupo '$1' no existe en LDAP."
        exit 
    fi
	echo "ldapdelete -x -D "$admin" -w "$ldappassword" "$dn_objeto""

}