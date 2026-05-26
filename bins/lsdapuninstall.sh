#!/bin/bash
# VARS
lsdapdir="/usr/local/share/lsdap"

echo "[!] You are one step to uninstall lsdap [!]" 
echo""
read -p "Are you sure?(Y/N) --> " confirmation
if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
	rm -r $lsdapdir
	sed -i '\#source /usr/share/bash-completion/completions/lsdap#d' ~/.bashrc
    rm /usr/bin/lsdap
	echo "Uninstalled"
else 
	echo "[#] ABORTING [#]"
fi
