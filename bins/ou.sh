#!/bin/bash


if [ -z "$(slapcat | grep ou)" ]; then
	echo "No Organizational Units found. You can create objects with lsdap -new, use -h for help."
	exit 1
fi

echo "Available Organizational Units:"

# Función recursiva que recibe el DN de la OU y el nivel de profundid
mostrarUnidades() {
    local datos="$1"
    local nivel="$2"

    # 1. Obtener el nombre limpio de la OU actual para mostrarlo
    local nombreOU=$(echo "$datos" | cut -d"," -f1 | sed 's/^ou=//g')
    
    # 2. Crear la indentación visual según el nivel actual
    local prefijo=""
    if [ "$nivel" -gt 0 ]; then
        # Genera espacios y un guión según la profundidad
        prefijo="$(printf '   %.0s' $(seq 1 $nivel))-"
    fi
    echo "${prefijo}${nombreOU}"

    # 3. Crear patrón para buscar las subunidades directas de esta OU
    echo "^dn: ou=[[:alnum:]\ _-]+,$datos$" > patron
    
    # Guardamos los DNs completos de las subunidades encontradas
    local subunidades=$(slapcat | grep -E -i -f patron | sed 's/^dn: //g')

    # 4. Si existen subunidades, llamamos recursivamente a la función aumentando el nivel
    if [ ! -z "$subunidades" ]; then
        for sub in $subunidades; do
            # Llamada recursiva: se pasa el DN de la subunidad y el nivel incrementado en 1
            mostrarUnidades "$sub" $((nivel + 1))
        done
    fi
}

# Obtener todas las unidades organizativas (OUs) raíz/principales (las que cuelgan del dc directo, no de otra ou)
unidades=$(slapcat | grep "^dn: ou=" | sed 's/^dn: //g' | grep -v ",ou=")

# Procesar las unidades organizativas principales (Nivel 0)
for uni in $unidades; do
    mostrarUnidades "$uni" 0
done

# Limpiar el archivo temporal de patrones
[ -f patron ] && rm patron