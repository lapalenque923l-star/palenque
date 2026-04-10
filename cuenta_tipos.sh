#!/bin/bash
# ------------------------------------------------------------
# Script: cuenta_tipos.sh
# Descripción: Cuenta cuántos ficheros de cada tipo hay en un
# directorio y muestra también sus nombres.
#
# Tipos considerados:
# - Ficheros de texto
# - Ficheros de dispositivo
# - Directorios
# - Ficheros ejecutables
#
# Si no se indica directorio, usa el directorio actual.
# Devuelve 0 si todo va bien y 1 en caso de error.
# ------------------------------------------------------------

set -u

# ------------------------------------------------------------
# Variables globales
# ------------------------------------------------------------
LOG_FILE="$HOME/cuenta_tipos.log"
DIRECTORIO="."

# Arrays para guardar nombres
textos=()
dispositivos=()
directorios=()
ejecutables=()

# ------------------------------------------------------------
# Función: log_msg
# Escribir mensajes en el archivo de log.
# ------------------------------------------------------------
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ------------------------------------------------------------
# Función: mostrar_ayuda
# Objetivo: Mostrar la ayuda del script.
# ------------------------------------------------------------
mostrar_ayuda() {
    echo "Uso: $0 [-d directorio] [-l archivo_log] [-h]"
    echo
    echo "Opciones:"
    echo "  -d   Directorio a explorar (por defecto el actual)"
    echo "  -l   Archivo de log personalizado"
    echo "  -h   Muestra esta ayuda"
}

# ------------------------------------------------------------
# Función: validar_directorio
# Objetivo: Comprobar que el directorio existe.
# ------------------------------------------------------------
validar_directorio() {
    if [ ! -d "$1" ]; then
        echo "ERROR: el directorio '$1' no existe."
        log_msg "ERROR: directorio no válido: $1"
        exit 1
    fi
}

# ------------------------------------------------------------
# Función: es_texto
# Objetivo: Determinar si un fichero es de texto usando file.
# ------------------------------------------------------------
es_texto() {
    local archivo="$1"
    file "$archivo" | grep -qi "text"
}

# ------------------------------------------------------------
# Función: es_dispositivo
# Objetivo: Determinar si un fichero es de dispositivo usando file.
# ------------------------------------------------------------
es_dispositivo() {
    local archivo="$1"
    file "$archivo" | grep -qi "device"
}
# ------------------------------------------------------------
# Función: unir_lista
# Objetivo: Mostrar una lista separada por comas. Si está vacía,
# mostrar "ninguno".
# ------------------------------------------------------------
unir_lista() {
    if [ "$#" -eq 0 ]; then
        echo "ninguno"
    else
        local IFS=", "
        echo "$*"
    fi
}

# ------------------------------------------------------------
# Tratamiento de parámetros. Getopts comprueba si las opciones 
# utilizadas están en la lista permitida o no, y si han sido 
# llamadas con un argumento adicional
# ------------------------------------------------------------
while getopts ":d:l:h" opt; do
    case "$opt" in
        d) DIRECTORIO="$OPTARG" ;;
        l) LOG_FILE="$OPTARG" ;;
        h)
            mostrar_ayuda
            exit 0
            ;;
        \?)
            echo "ERROR: opción no válida: -$OPTARG"
            mostrar_ayuda
            exit 1
            ;;
        :)
            echo "ERROR: la opción -$OPTARG requiere un valor"
            mostrar_ayuda
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------
# Validación inicial
# ------------------------------------------------------------
validar_directorio "$DIRECTORIO"
log_msg "Exploración iniciada sobre el directorio: $DIRECTORIO"

# ------------------------------------------------------------
# Programa principal
# Objetivo: # Recorrer el directorio y clasificar cada entrada.
# ------------------------------------------------------------
for archivo in "$DIRECTORIO"/*; do
    [ -e "$archivo" ] || continue

    nombre=$(basename "$archivo")

    if [ -d "$archivo" ]; then
        directorios+=("$nombre")
        log_msg "Directorio detectado: $nombre"

    elif [ -f "$archivo" ] && [ -x "$archivo" ]; then
        ejecutables+=("$nombre")
        log_msg "Ejecutable detectado: $nombre"

    elif es_dispositivo "$archivo"; then
        dispositivos+=("$nombre")
        log_msg "Dispositivo detectado: $nombre"

    elif es_texto "$archivo"; then
        textos+=("$nombre")
        log_msg "Texto detectado: $nombre"
    fi
done

# ------------------------------------------------------------
# Salida final
# ------------------------------------------------------------
echo "La clasificación de ficheros del directorio $DIRECTORIO es:"
echo "Hay ${#textos[@]} ficheros de texto: $(unir_lista "${textos[@]}")"
echo "Hay ${#dispositivos[@]} ficheros de dispositivo: $(unir_lista "${dispositivos[@]}")"
echo "Hay ${#directorios[@]} directorios: $(unir_lista "${directorios[@]}")"
echo "Hay ${#ejecutables[@]} ficheros ejecutables: $(unir_lista "${ejecutables[@]}")"

log_msg "Exploración finalizada correctamente"
exit 0
