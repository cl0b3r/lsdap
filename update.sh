#!/bin/bash

# Solución al crash por git pull: Forzamos a Bash a leer el script completo en memoria
# si no ha sido cargado mediante un truco de redirección interna.
if [ -z "$SCRIPT_LOADED" ]; then
    export SCRIPT_LOADED=1
    exec bash << 'EOF'
#!/bin/bash

# ROOT CHECK
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root. Please use sudo."
        echo ""
        exit 1
    fi

# VARS
    lsdapdir="/usr/local/share/lsdap"
    localbins="./bins"
    lsdapbins="$lsdapdir/bins"
    lsdapdata="$lsdapdir/data.conf"
    lsdapfile="$lsdapdir/file.ldif"
    lsdapanyssh="$lsdapdir/AnyDeskSSH"

#--------------------------------------

# Comprobación de actualización robusta e independiente del idioma
git fetch &> /dev/null
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "Already up to date"
    exit 0
else
    echo "Updating..."
    
    # Limpiamos cambios locales y descargamos lo nuevo
    git reset --hard origin/$(git branch --show-current) > /dev/null 2>&1
    git pull > /dev/null 2>&1

    # Salvaguarda de datos del usuario
    mkdir -p /tmp/lsdapupdate
    if [ -f "$lsdapdata" ]; then
        cp "$lsdapdata" /tmp/lsdapupdate/
        cp -r "$lsdapanyssh" /tmp/lsdapupdate/

    fi

    # Reestructuración del directorio de la app
    rm -rf "$lsdapdir"
    mkdir -p "$lsdapbins"
    touch "$lsdapfile"
    
    # Copiar nuevos ejecutables
    cp -r $localbins/* "$lsdapbins/" 2>/dev/null
    
    # Restaurar data.conf si existía previamente
    if [ -f "/tmp/lsdapupdate/data.conf" ]; then
        cp -r /tmp/lsdapupdate/* "$lsdapdir/"
    fi
    rm -rf /tmp/lsdapupdate 
    
    # Permisos
    chmod 755 "$lsdapbins"/* 2>/dev/null
    chmod 755 $lsdapanyssh 2>/dev/null
    chmod 700 $lsdapanyssh/* 2>/dev/null
    chmod 755 update.sh
    chmod 755 set-up.sh
    
    # Obtener el usuario real que invocó el sudo de forma nativa
    REAL_USER=${SUDO_USER:-$(id -nu 1000)}
    chown "$REAL_USER:$REAL_USER" update.sh
    chown "$REAL_USER:$REAL_USER" set-up.sh

    echo "Update completed successfully!"
fi
EOF
    exit $?
fi