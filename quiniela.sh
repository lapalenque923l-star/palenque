#!/bin/bash
# ------------------------------------------------------------
# Script: quiniela
# Descripción: Genera una quiniela simple de 14 partidos, asignando de forma aleatoria un resultado: 1, X o 2.
# Con funciones, parámetros, logs y control de errores.
# ------------------------------------------------------------

set -u # Activa error si hay variables no definidas

# Archivo de log por defecto
LOG_FILE="$HOME/quiniela.log"

# Número de partidos por defecto
PARTIDOS=14

# ------------------------------------------------------------
# Función: log_msg
# Guardar mensajes en el archivo de log con fecha y hora.
# ------------------------------------------------------------
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ------------------------------------------------------------
# Función: mostrar_ayuda
# Objetivo: Mostrar la ayuda del script.
# ------------------------------------------------------------
mostrar_ayuda() {
    echo "Uso: $0 [-n numero_partidos] [-l archivo_log] [-h]"
    echo
    echo "Opciones:"
    echo "  -n   Número de partidos a generar (por defecto 14)"
    echo "  -l   Archivo de log personalizado"
    echo "  -h   Muestra esta ayuda"
}

# ------------------------------------------------------------
# Función: validar_numero
# Objetivo: Comprobar que el número de partidos sea un entero positivo.
# ------------------------------------------------------------
validar_numero() {
    if ! [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        echo "ERROR: el número de partidos debe ser un entero positivo."
        log_msg "ERROR: número de partidos no válido: $1"
        exit 1
    fi
}

# ------------------------------------------------------------
# Función: generar_resultado
# Objetivo: Generar un resultado aleatorio entre 1, X o 2.
# ------------------------------------------------------------
generar_resultado() {
    local valor=$((RANDOM % 3))

    case "$valor" in
        0) echo "1" ;;
        1) echo "X" ;;
        2) echo "2" ;;
    esac
}

# ------------------------------------------------------------
# Tratamiento de parámetros con getopts
# ------------------------------------------------------------
while getopts ":n:l:h" opt; do
    case "$opt" in
        n) PARTIDOS="$OPTARG" ;;
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

# Validamos el número de partidos
validar_numero "$PARTIDOS"

# Guardamos en el log el inicio de ejecución
log_msg "Inicio de generación de quiniela con $PARTIDOS partidos"

# ------------------------------------------------------------
# Programa principal
# Objetivo: Generar y mostrar la quiniela alineada.
# ------------------------------------------------------------
for ((i=1; i<=PARTIDOS; i++)); do
    resultado=$(generar_resultado)
    printf "%2d.- %s\n" "$i" "$resultado"
    log_msg "Partido $i -> $resultado"
done

# Guardamos en el log el fin de ejecución
log_msg "Fin de generación de quiniela"