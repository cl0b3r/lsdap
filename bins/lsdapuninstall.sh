#!/bin/bash
# VARS
    lsdapdir="/etc/lsdap"

	echo "[!] You are one step to uninstall lsdap [!]" 
	echo""
	read -p "Are you sure?(Y/N) --> " confirmation
		if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
			rm -r $lsdapdir
			rm /usr/bin/lsdap
			rm -r /usr/share/bash-completion/completions/lsdap
			sed -i 
		echo "Uninstalled"
		else 
			echo "[#] ABORTING [#]"
        fi
