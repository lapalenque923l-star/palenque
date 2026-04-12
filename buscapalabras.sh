#!/bin/bash

# =========================================================
# buscapalabras.sh
# Busca palabras de un fichero dentro de otro fichero
# y muestra cuántas veces aparece cada una.
# No distingue mayúsculas/minúsculas.
# =========================================================

LOGFILE="buscapalabras.log"

mostrar_ayuda() {
    echo "Uso: $0 ficherodepalabras ficherodebusqueda"
    echo
    echo "Descripción:"
    echo "  Lee una lista de palabras (una por línea) y busca cuántas veces"
    echo "  aparece cada palabra en el fichero de búsqueda."
    echo
    echo "Características:"
    echo "  - No distingue mayúsculas y minúsculas."
    echo "  - Si una palabra aparece repetida en el fichero de palabras,"
    echo "    se considera solo una vez."
    echo "  - El resultado se ordena de forma creciente por apariciones."
    echo
    echo "Opciones:"
    echo "  -h, --help    Muestra esta ayuda"
}

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

error_salida() {
    echo "Error: $1" >&2
    log_msg "ERROR: $1"
    exit 1
}

comprobar_parametros() {
    if [ $# -eq 1 ]; then
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            mostrar_ayuda
            exit 0
        fi
    fi

    if [ $# -ne 2 ]; then
        error_salida "Número de parámetros incorrecto."
    fi
}

comprobar_ficheros() {
    if [ ! -f "$1" ]; then
        error_salida "El fichero de palabras '$1' no existe."
    fi

    if [ ! -r "$1" ]; then
        error_salida "No se puede leer el fichero de palabras '$1'."
    fi

    if [ ! -f "$2" ]; then
        error_salida "El fichero de búsqueda '$2' no existe."
    fi

    if [ ! -r "$2" ]; then
        error_salida "No se puede leer el fichero de búsqueda '$2'."
    fi
}

buscar_palabras() {
    local fichero_palabras="$1"
    local fichero_busqueda="$2"
    local palabra
    local contador

    tmpfile=$(mktemp) || error_salida "No se pudo crear fichero temporal."

    # sort -fu elimina duplicados ignorando mayúsculas/minúsculas
    while IFS= read -r palabra; do
        # Saltar líneas vacías
        if [ -n "$palabra" ]; then
            contador=$(grep -owi "$palabra" "$fichero_busqueda" | wc -l)
            echo "$palabra $contador" >> "$tmpfile"
            log_msg "Palabra '$palabra' encontrada $contador veces"
        fi
    done < <(sort -fu "$fichero_palabras")

    sort -k2,2n -k1,1 "$tmpfile"
    rm -f "$tmpfile"
}

main() {
    log_msg "Inicio del script"

    comprobar_parametros "$@"
    comprobar_ficheros "$1" "$2"
    buscar_palabras "$1" "$2"

    log_msg "Fin del script"
}

main "$@"