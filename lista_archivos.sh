#!/bin/bash
# ------------------------------------------------------------
# Script: lista_archivos.sh
# Descripción:
# Lista los archivos de un directorio e indica su tipo.
#
# Requisitos del ejercicio:
# 1) Usar un bucle for y un comodín (*) para recorrer archivos.
# 2) Indicar si cada entrada es:
#    - Directorio
#    - Archivo ejecutable
#    - Archivo normal
# 3) Modificación: mostrar el símbolo AL FINAL del nombre,
#    como hace el comando ls -F.
# 4) Modificación: aceptar un directorio como parámetro y usar
#    el directorio actual si no se pasa ninguno.
# ------------------------------------------------------------

set -u

# ------------------------------------------------------------
# Variables globales
# ------------------------------------------------------------

# Archivo de log por defecto
LOG_FILE="$HOME/lista_archivos.log"

# Directorio por defecto
# Esta línea responde a la modificación del ejercicio:
# si el usuario no pasa ningún directorio, se usa ".",
# que representa el directorio actual.
DIRECTORIO="."

# ------------------------------------------------------------
# Función: log_msg
# Objetivo:
# Guardar mensajes en el archivo de log con fecha y hora.
# ------------------------------------------------------------
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ------------------------------------------------------------
# Función: mostrar_ayuda
# Objetivo:
# Mostrar la sintaxis del script y sus opciones.
# ------------------------------------------------------------
mostrar_ayuda() {
    echo "Uso: $0 [-d directorio] [-l archivo_log] [-h]"
    echo
    echo "Opciones:"
    echo "  -d   Directorio a listar (por defecto el actual)"
    echo "  -l   Archivo de log personalizado"
    echo "  -h   Muestra esta ayuda"
}

# ------------------------------------------------------------
# Función: validar_directorio
# Objetivo:
# Comprobar que el directorio indicado existe.
# ------------------------------------------------------------
validar_directorio() {
    if [ ! -d "$1" ]; then
        echo "ERROR: el directorio '$1' no existe."
        log_msg "ERROR: directorio no válido: $1"
        exit 1
    fi
}

# ------------------------------------------------------------
# Función: obtener_simbolo_final
# Objetivo:
# Devolver el símbolo que irá al FINAL del nombre del archivo.
#
# Esta función responde a la modificación del ejercicio que pide
# mostrar el símbolo al final, igual que ls -F:
#   / para directorios
#   * para ejecutables
#   nada para archivos normales
# ------------------------------------------------------------
obtener_simbolo_final() {
    local ruta="$1"

    if [ -d "$ruta" ]; then
        echo "/"
    elif [ -f "$ruta" ] && [ -x "$ruta" ]; then
        echo "*"
    else
        echo ""
    fi
}

# ------------------------------------------------------------
# Tratamiento de parámetros con getopts
# Objetivo:
# Permitir indicar un directorio con -d.
#
# Esto también responde a la modificación del ejercicio:
# el script puede recibir un directorio por línea de comandos,
# y si no se indica ninguno, se mantiene el valor por defecto
# del directorio actual.
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
# Validación del directorio
# ------------------------------------------------------------
validar_directorio "$DIRECTORIO"
log_msg "Listado iniciado sobre el directorio: $DIRECTORIO"

# ------------------------------------------------------------
# Programa principal
# Objetivo:
# Recorrer los archivos usando un bucle for y el comodín *
#
# Se usa:
#   for archivo in "$DIRECTORIO"/*
# para cumplir exactamente lo que pide el ejercicio:
# recorrer con un bucle for y un wildcard (*).
# ------------------------------------------------------------
for archivo in "$DIRECTORIO"/*; do
    # Si el directorio está vacío, el patrón puede no coincidir.
    # Esta comprobación evita errores.
    [ -e "$archivo" ] || continue

    # Obtenemos solo el nombre base del archivo, sin la ruta
    nombre=$(basename "$archivo")

    # Obtenemos el símbolo final según el tipo
    simbolo_final=$(obtener_simbolo_final "$archivo")

    # Mostramos el nombre con el símbolo AL FINAL.
    # Ejemplos:
    #   Documentos/
    #   script.sh*
    #   notas.txt
    echo "${nombre}${simbolo_final}"

    # Guardamos la salida en el log
    log_msg "Entrada listada: ${nombre}${simbolo_final}"
done

log_msg "Listado finalizado"