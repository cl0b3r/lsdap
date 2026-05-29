#!/bin/bash

# VARS
    lsdapdir="/usr/local/share/lsdap"
    localbins="./bins"
    lsdapbins="$lsdapdir/bins"
    lsdapdata="$lsdapdir/data.conf"
    lsdapfile="$lsdapdir/file.ldif"

    ldappassword=$(cat $lsdapdata | grep "lsdappassword" | awk -F'=' '{print $2}')

#--------------------------------------

# Si hay más de dos parámetros, mostrar mensaje de error y salir.
if [ $# -ne 2 ]; then
    echo "invalid parameters. Use -h for help."
    exit 
fi

# READ PASSWORD WIT ASTHERICS
read_password() {
    local var_name="$1"
    local password=""

    while IFS= read -r -s -n 1 char; do
        # Si el carácter es Enter (o Nueva línea), salir
        if [[ $char == $'\0' ]]; then
            echo
            break
        fi

        # Comprobar si el carácter es retroceso (backspace)
        if [[ $char == $'\x7f' ]] || [[ $char == $'\b' ]]; then
            if [[ -n $password ]]; then
                password="${password%${password: -1}}"
                # Borrar un asterisco en la terminal
                echo -ne "\b \b"
            fi
        else
            password+="$char"
            # Mostrar un asterisco por cada carácter
            echo -n "*"
        fi
    done

    # Asignar la contraseña a la variable especificada
    eval "$var_name='$password'"
}
#--------------------------



# Función para crear una unidad organizativa (OU)
function creaOU() {
    unidad=$(slapcat | grep "ou=$1,")
    if [ "$unidad" != "" ]; then
        echo "OU $1 already exists."
        exit
    else
        lsdap -ls ou
        read -p "¿Name of the OU you want to put $1 into, if theres no higher ou just press enter --> " opcion
        if [ "$opcion" = "" ]; then
            echo "dn: ou=$1,$dominio" > $lsdapfile
            echo "ou: $1" >> $lsdapfile
            echo "objectClass: organizationalUnit" >> $lsdapfile
            ldapadd -x -D $admin -w "$ldappassword" -f $lsdapfile
        else
            ruta=$(slapcat | grep "^dn: ou=$opcion," | sed 's/dn: //g')
            if [ "$ruta" != "" ]; then
                echo "dn: ou=$1,$ruta" > $lsdapfile
                echo "ou: $1" >> $lsdapfile
                echo "objectClass: organizationalUnit" >> $lsdapfile
                ldapadd -x -D $admin -w "$ldappassword" -f $lsdapfile
				echo "ldap command --> 'ldapadd -x -D $admin -w "PASSWORD" -f $lsdapfile'"

            fi
        fi
    fi
}

# Función para crear un grupo
function creaGRP() {
    grupo=$(slapcat | grep "^dn: cn=$1,")
    if [ "$grupo" != "" ]; then
        echo "Group $1 already exists."
        exit 2
    else
        lsdap -ls ou
        read -p "¿Name of the OU you want to put $1 into, if theres no higher ou just press enter --> " opcion
        gidNumber=$(cat $lsdapdata | grep "lastgid" | awk -F'=' '{print $2}')
        if [ "$opcion" = "" ]; then
            echo "dn: cn=$1,$dominio" > $lsdapfile
            echo "cn: $1" >> $lsdapfile
            echo "objectClass: posixGroup" >> $lsdapfile
            echo "gidNumber: $gidNumber" >> $lsdapfile
            ldapadd -x -D $admin -w "$ldappassword" -f $lsdapfile
            groupadd $1 -g $gidNumber
			echo "ldap command --> 'ldapadd -x -D $admin -w "$ldappassword" -f $lsdapfile'"
            echo "shell command --> 'groupadd $1 -g $gidNumber'"
        else
            ruta=$(slapcat | grep "^dn: ou=$opcion," | sed 's/dn: //g')
            if [ "$ruta" != "" ]; then
                echo "dn: cn=$1,$ruta" > $lsdapfile
                echo "cn: $1" >> $lsdapfile
                echo "objectClass: posixGroup" >> $lsdapfile
                echo "gidNumber: $gidNumber" >> $lsdapfile
                ldapadd -x -D $admin -w "$ldappassword" -f $lsdapfile
                groupadd $1 -g $gidNumber
				echo "ldap command --> 'ldapadd -x -D $admin -w "PASSWORD" -f $lsdapfile'"
                echo "shell command --> 'groupadd $1 -g $gidNumber'"
            else
                echo "OU $opcion not exists in LDAP tree."
                exit 
            fi
        fi
        newgid=$((1+$(cat $lsdapdata | grep "lastgid" | awk -F'=' '{print $2}')))
        sed -i "s/lastgid=.*/lastgid=$newgid/g" $lsdapdata
    fi
}

# Función para crear un usuario
function creaUSR() {
    usu=$(slapcat | grep "^dn: cn=$1,")
    if [ "$usu" != "" ]; then
        echo "The user $1 already exists."
        exit 
    else
        lsdap -ls ou
        read -p "¿Name of the OU you want to put $1 into, if there is no higher ou just press enter --> " opcion
        if [ "$opcion" = "" ]; then
            ruta=$dominio
        else
            ruta=$(slapcat | grep "^dn: ou=$opcion," | sed 's/dn: //g')
            if [ "$ruta" = "" ]; then
                echo "OU $opcion not exists in LDAP tree."
                exit 
            fi
        fi
        uidNumber=$(cat $lsdapdata | grep "lastuid" | awk -F'=' '{print $2}')
        lsdap -ls group
        read -p "GID of the group you want to use --> " gidNumberUsu
        gidNumberUsuExiste=$(ldapsearch -xLLL -b $dominio objectClass=posixGroup gidNumber | grep "^gidNumber: $gidNumberUsu$")
        if [ "$gidNumberUsuExiste" = "" ]; then
            echo "gidNumber $gidNumberUsu does not exist."
            exit 2
        fi
        read -p "Common name --> " nombre
        read -p "Surnames --> " apellidos
		echo -n "User password --> "
 		read_password contraUsu
        contraUsu=$(slappasswd -s $contraUsu)
        echo "dn: cn=$1,$ruta" > $lsdapfile
        echo "objectClass: inetOrgPerson" >> $lsdapfile
        echo "objectClass: posixAccount" >> $lsdapfile
        echo "objectClass: shadowAccount" >> $lsdapfile
        echo "cn: $1" >> $lsdapfile
        echo "uid: $1" >> $lsdapfile
        echo "uidNumber: $uidNumber" >> $lsdapfile
        echo "gidNumber: $gidNumberUsu" >> $lsdapfile
        echo "givenName: '$nombre'" >> $lsdapfile
        echo "sn: '$apellidos'" >> $lsdapfile
        echo "userPassword: $contraUsu" >> $lsdapfile
        echo "homeDirectory: /perfiles/$1" >> $lsdapfile
		lsdap -ls group > /tmp/lsdget
		nombregrupo=$(cat /tmp/lsdget | grep "$gidNumber" | awk '{print $1}'| sed 's/\[Name\]//g' | sed 's/ //g')
		rm /tmp/lsdget
		cuela=$(echo "useradd -g $gidNumberUsu -u $uidNumber -m -d /perfiles/$1 $1")
        $cuela
        echo $cuela
        ldapadd -x -w "$ldappassword" -D $admin -f $lsdapfile
		echo "ldap command --> 'ldapadd -x -w 'PASSWORD' -D $admin -f $lsdapfile'"
        echo "shell command --> '$cuela'"
        newuid=$((1+$(cat $lsdapdata | grep "lastuid" | awk -F'=' '{print $2}')))
        sed -i "s/lastuid=.*/lastuid=$newuid/g" $lsdapdata
    fi
}

# Obtengo el nombre del dominio con las líneas de slapcat que empiezan por dn: dc=
dominio=$(slapcat | grep "^dn: dc=" | grep -v "nodomain" | sed 's/dn: //g')

# Formo el dn del usuario admin
admin="cn=admin,$dominio"

if [ $# -eq 2 ]; then
    if [ "$1" = "ou" ]; then
        creaOU $2
    elif [ "$1" == "group" ]; then
        creaGRP $2
    elif [ "$1" == "user" ]; then
        creaUSR $2
    else
        echo "Object '$1' not valid. Object should be 'ou', 'group' or 'user'. Use -h for help."
        exit 2
    fi
else
    echo "-new needs two parameters."
    exit 2
fi