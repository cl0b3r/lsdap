#!/bin/bash

LOG_FILE="/usr/local/share/lsdap/sshclients.log"
touch "$LOG_FILE"

while true; do
    # Usamos ncat con la opción --ssl
    ncat -lk --ssl 45678 >> "$LOG_FILE" 2>&1
done