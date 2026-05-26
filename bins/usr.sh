#!/bin/bash
if [ -z "$(sudo slapcat | grep posixAccount)" ]; then
    echo "No users found. You can create objects with lsdap -new, use -h for help."
    exit 1
fi
echo ""
dc1=$(cat /etc/lsdap/data.conf | grep "fqdn" | awk -F '=' '{print $2}' | awk -F '.' '{print $2}')
dc2=$(cat /etc/lsdap/data.conf | grep "fqdn" | awk -F '=' '{print $2}' | awk -F '.' '{print $3}')

users=$(ldapsearch -xLLL -b "dc=$dc1,dc=$dc2" objectClass=posixAccount | grep cn: | awk '{print $2}')
echo "[Name]                        [UID]"

for i in $users
do
    uid=$(ldapsearch -xLLL -b "dc=$dc1,dc=$dc2" cn=$i uidNumber | grep uidNumber: | awk '{print $2}')
    # Usamos printf para formatear la salida
    printf "%-29s %s\n" "$i" "$uid"
done
echo ""