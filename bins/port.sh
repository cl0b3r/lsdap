#!/bin/bash

# VARS
    lsdapdir="/usr/local/share/lsdap"
    lsdapanyssh="$lsdapdir/AnyDeskSSH"
    
#---------------------------------------


logSSH="$lsdapanyssh/ssh_hosts.logs"
logAnyDesk="$lsdapanyssh/ad_hosts.logs"
logError="$lsdapanyssh/error.log"

while true; do
    ncat -lk --ssl 45678 2>> "$logError" | while IFS= read -r linea; do
        
        case "$linea" in
            "ssh:"*)
                echo "${linea#ssh: }" >> "$logSSH"
                ;;
                
            "ad:"*)
                echo "${linea#ad: }" >> "$logAnyDesk"
                ;;
                
            *)
                echo "[Desconocido] $linea" >> "$logError"
                ;;
        esac
    done    
    sleep 2
done