#!/bin/bash
# ROOT CHECK
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root. Please use sudo."
        echo ""
        exit 1
    fi

read -p "You are about to enable getcr service. Do you want to continue? (y/n) " answer

if [[ "$answer" != "y" ]]; then
    echo "Cancelled."
    exit 0
fi

chmod 755 *
systemctl daemon-reload
sudo systemctl enable getcr.service


