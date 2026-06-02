#!/bin/bash

# VARS
lsdapdir="/usr/local/share/lsdap"
logs="$lsdapdir/logs"

#---------------------------------------

logSSH="$logs/ssh_hosts.logs"
logAnyDesk="$logs/ad_hosts.logs"
logIH="$logs/ih_hosts.logs"
logError="$logs/error.logs"

# Asegurar que el directorio de logs exista si corre como root de cero
mkdir -p "$logs"

# Escuchar de forma permanente
ncat -lk --ssl 45678 2>> "$logError" | while IFS= read -r linea; do
    case "$linea" in
        "ssh:"*)
            echo "${linea#ssh: }" >> "$logSSH"
            ;;

        "ad:"*)
            echo "${linea#ad: }" >> "$logAnyDesk"
            ;;

        "ih:"*)
            echo "${linea#ih: }" >> "$logIH"
            ;;

        *)
            echo "$linea" >> "$logError"
            ;;
    esac
done