#!/bin/bash
# Script: selector_saludo_aleatorio
# Objetivo: mostrar un saludo (buenos días, buenas tardes o noches)
#           usando cowsay y un muñeco aleatorio.
# Plataforma: Ubuntu (y derivados) con repositorio apt.
# Carpeta de muñecos: /usr/share/cowsay/cows (típica de Ubuntu/Debian).

# ------------------------------------------------------------
# 1. Comprobar que cowsay está instalado
# Si no lo está, se muestra un mensaje de instalación y se sale.
# ------------------------------------------------------------

if ! command -v cowsay >/dev/null 2>&1; then
    echo "ERROR: el comando 'cowsay' no está instalado en el sistema."
    echo "Para instalarlo en Ubuntu o Debian, ejecuta:"
    echo "    sudo apt update"
    echo "    sudo apt install cowsay"
    echo "Después vuelve a ejecutar este script."
    exit 1
fi

# ------------------------------------------------------------
# 2. Obtener la hora actual y elegir el saludo
# ------------------------------------------------------------

# Obtenemos la hora actual en formato 00-23
hora=$(date +%H)

# Según la hora del día elegimos el saludo
if [ "$hora" -ge 6 ] && [ "$hora" -lt 12 ]; then
    saludo="Buenos días"
elif [ "$hora" -ge 12 ] && [ "$hora" -lt 20 ]; then
    saludo="Buenas tardes"
else
    saludo="Buenas noches"
fi

# ------------------------------------------------------------
# 3. Directorio de muñecos y verificación
# ------------------------------------------------------------

# En Ubuntu, los ficheros de muñecos de cowsay suelen estar en
# /usr/share/cowsay/cows (definido por el paquete cowsay).
directorio_cows="/usr/share/cowsay/cows"

# Comprobamos que la carpeta de muñecos exista
if [ ! -d "$directorio_cows" ]; then
    echo "ERROR: no se encuentra la carpeta de muñecos de cowsay:"
    echo "    $directorio_cows"
    echo "Asegúrate de que cowsay está instalado correctamente."
    exit 1
fi

# ------------------------------------------------------------
# 4. Elegir un muñeco aleatorio
# ------------------------------------------------------------

# Seleccionamos un fichero con extensión .cow dentro de la carpeta
cowfile=$(find "$directorio_cows" -type f -name "*.cow" | shuf -n 1)

# Extraemos solo el nombre del fichero (sin ruta y sin .cow)
cowfile=$(basename "$cowfile" .cow)

# ------------------------------------------------------------
# 5. Mostrar el saludo usando cowsay
# ------------------------------------------------------------

# Llamamos a cowsay con el muñeco seleccionado y el saludo
cowsay -f "$cowfile" "$saludo"

# Fin del script
