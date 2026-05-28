#!/bin/bash

# Si el usuario no es root, muestra un error y sale con 2
if [ $(id -u) -ne 0 ]; then
    echo "Permission denied."
    exit 2
fi

if [ $# -gt 2 ]; then
    echo "Numbers of params incorrect."
    exit 2
fi

if [ $# -eq 1 ]; then
	echo "Missing object name. "
	exit 2
fi


# VARS
lsdapdir="/usr/local/share/lsdap"
lsdapdata="$lsdapdir/data.conf"

dominio=$(slapcat | grep "^dn: dc=" | grep -v "nodomain" | head -n 1 | sed 's/dn: //g')
admin="cn=admin,$dominio"
ldappassword=$(grep "lsdappassword" "$lsdapdata" | awk -F'=' '{print $2}')
# Función auxiliar para "desplegar" las líneas de slapcat
unfold_ldif() {
    awk '/^ / {printf "%s", substr($0,2); next} {printf "%s%s", (NR==1?"":ORS), $0} END {print ""}'
}

deleteuser() {
    # Buscamos SOLO objetos que tengan el cn del usuario Y sean de la clase de usuarios (posixAccount o inetOrgPerson)
    dn_objeto=$(slapcat -a "(&(cn=$1)(objectClass=posixAccount))" | unfold_ldif | grep -i "^dn:" | sed 's/dn: //g')
    
    if [ -z "$dn_objeto" ]; then
        echo "User '$1' not found in LDAP."
        exit 1
    fi
    
    ldapdelete -x -D "$admin" -w "$ldappassword" "$dn_objeto"
    echo "User LDAP '$1' deleted."

    if id "$1" &>/dev/null; then
        userdel -r "$1" 2>/dev/null
        echo "Linux user '$1' deleted."
    fi
}
deletegroup() {
    # Buscamos SOLO objetos que sean de la clase de grupos (posixGroup)
    dn_objeto=$(sudo slapcat -a "(&(cn=$1)(objectClass=posixGroup))" | unfold_ldif | grep -i "^dn:" | sed 's/dn: //g')
    
    if [ -z "$dn_objeto" ]; then
        echo "Group '$1' not found in LDAP."
        exit 1
    fi
    
    ldapdelete -x -D "$admin" -w "$ldappassword" "$dn_objeto"
	groupdel $1 2>/dev/null
	echo "Linux and LDAP group '$1' deleted." 

}

deleteou() {
    dn_objeto=$(slapcat -a "(ou=$1)" | unfold_ldif | grep -i "^dn:" | sed 's/dn: //g')
    if [ -z "$dn_objeto" ]; then
        echo "Organizational Unit '$1' not found in LDAP."
        exit 1
    fi


	ou_ruta=$(slapcat | grep "^dn: ou=$1" | awk '{print $2}')


	# Eliminar los usuarios que estén dentro de la OU antes de eliminar la OU
	usuarios=$(slapcat -H "ldap:///$ou_ruta??sub?(objectClass=posixAccount)" | grep "^dn: cn=" | awk -F '=' '{print $2}' | awk -F ',' '{print $1}' )
	for i in $usuarios
	do
		userdel -r $i 2>/dev/null
		echo "Linux and LDAP user '$i' deleted."
	done 

	# Eliminar los grupos que estén dentro de la OU
	grupos=$(slapcat -H "ldap:///$ou_ruta??sub?(objectClass=posixGroup)" | grep "^dn: cn=" | awk -F '=' '{print $2}' | awk -F ',' '{print $1}')
	for i in $grupos
	do
		groupdel "$i" 2>/dev/null
		echo "Linux and LDAP group '$i' deleted." 
	done


	# Eliminar la OU y todo su contenido (usuarios, grupos, etc.) de forma recursiva en LDAP
    ldapdelete -x -r -D "$admin" -w "$ldappassword" "$dn_objeto"
	echo "Organizational Unit LDAP '$1' deleted."

}

if [ "$1" = "user" ]; then
    deleteuser "$2"
elif [ "$1" = "ou" ]; then
    deleteou "$2"
elif [ "$1" = "group" ]; then
    deletegroup "$2"
else 
    echo "Object '$1' not valid. Object should be 'ou', 'group' or 'user'."
    exit 2
fi