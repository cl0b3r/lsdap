#!/bin/bash

# CONFIGURACIÓN
SERVER_IP="IP_DEL_SERVIDOR"
SERVER_PORT="45678"
INTERVAL=60 # Tiempo en segundos para comprobar si cambió la IP

LAST_IP=""

while true; do
    # 1. Obtener el hostname
    HOSTNAME=$(hostname)

    # 2. Obtener la IP activa y su CIDR (ej. 192.168.1.50/24)
    # Filtra la interfaz loopback (lo) y busca la IP primaria instalada
    CURRENT_IP_CIDR=$(ip -o -4 addr show | awk '$2 != "lo" {print $4}' | head -n 1)

    # Si por algún motivo no hay red aún, espera y reintenta
    if [ -z "$CURRENT_IP_CIDR" ]; then
        sleep 10
        continue
    fi

    # 3. Si la IP cambió respecto a la última comprobación, la enviamos
    if [ "$CURRENT_IP_CIDR" != "$LAST_IP" ]; then
        
        # Formato requerido: (ih: hostname IP/CIDR)
        MESSAGE="(ih: ${HOSTNAME} ${CURRENT_IP_CIDR})"
        
        # Enviar usando ncat con cifrado SSL
        echo "$MESSAGE" | ncat --ssl "$SERVER_IP" "$SERVER_PORT"
        
        # Actualizar el estado de la última IP enviada con éxito
        if [ $? -eq 0 ]; then
            LAST_IP="$CURRENT_IP_CIDR"
        fi
    fi

    sleep "$INTERVAL"
done