#!/bin/bash
# ------------------------------------------------------------
# Script: selector_saludo_aleatorio
# Autor: ---
# Sistema: Ubuntu / Debian
# Descripción:
# Este script muestra un saludo con cowsay según la hora del
# día o según un parámetro indicado por el usuario.
# Además, registra la ejecución en un archivo de log.
# ------------------------------------------------------------

# Activamos el control para que Bash avise si se usa
# una variable no inicializada.
set -u

# ------------------------------------------------------------
# Variables globales del script
# ------------------------------------------------------------

# Archivo de log por defecto
LOG_FILE="$HOME/selector_saludo_aleatorio.log"

# Directorio donde están los cowfiles en Ubuntu/Debian
DIRECTORIO_COWS="/usr/share/cowsay/cows"

# Variable para forzar un saludo manualmente con parámetros
SALUDO_FORZADO=""

# ------------------------------------------------------------
# Función: log_msg
# Objetivo:
# Guardar en el archivo de log un mensaje con fecha y hora.
# ------------------------------------------------------------
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ------------------------------------------------------------
# Función: mostrar_ayuda
# Objetivo:
# Mostrar al usuario cómo se utiliza el script y qué opciones
# admite por línea de comandos.
# ------------------------------------------------------------
mostrar_ayuda() {
    echo "Uso: $0 [-m manana|tarde|noche] [-l archivo_log] [-h]"
    echo
    echo "Opciones:"
    echo "  -m   Fuerza el saludo: manana, tarde o noche"
    echo "  -l   Permite indicar un archivo de log personalizado"
    echo "  -h   Muestra esta ayuda"
}

# ------------------------------------------------------------
# Función: comprobar_cowsay
# Objetivo:
# Verificar que el comando cowsay está instalado en el sistema.
# Si no está instalado, muestra el comando de instalación para
# Ubuntu/Debian y finaliza el script.
# ------------------------------------------------------------
comprobar_cowsay() {
    if ! command -v cowsay >/dev/null 2>&1; then
        echo "ERROR: cowsay no está instalado en el sistema."
        echo "Instálalo con los siguientes comandos:"
        echo "sudo apt update"
        echo "sudo apt install cowsay"
        log_msg "ERROR: cowsay no está instalado"
        exit 1
    fi
}

# ------------------------------------------------------------
# Función: obtener_saludo
# Objetivo:
# Devolver el saludo que se va a mostrar.
# Si el usuario ha indicado un saludo con -m, se usa ese.
# Si no, se calcula automáticamente a partir de la hora actual.
# ------------------------------------------------------------
obtener_saludo() {
    local hora

    # Si el usuario ha forzado un saludo por parámetro,
    # se comprueba su valor.
    if [ -n "$SALUDO_FORZADO" ]; then
        case "$SALUDO_FORZADO" in
            manana) echo "Buenos días" ;;
            tarde)  echo "Buenas tardes" ;;
            noche)  echo "Buenas noches" ;;
            *)
                echo "ERROR: valor no válido para -m"
                log_msg "ERROR: parámetro -m inválido: $SALUDO_FORZADO"
                exit 1
                ;;
        esac
        return
    fi

    # Si no se ha forzado ningún saludo, se obtiene la hora actual
    hora=$(date +%H)

    # Según la hora se devuelve el saludo correspondiente
    if [ "$hora" -ge 6 ] && [ "$hora" -lt 12 ]; then
        echo "Buenos días"
    elif [ "$hora" -ge 12 ] && [ "$hora" -lt 20 ]; then
        echo "Buenas tardes"
    else
        echo "Buenas noches"
    fi
}

# ------------------------------------------------------------
# Función: elegir_cowfile
# Objetivo:
# Seleccionar de forma aleatoria uno de los muñecos disponibles
# en la carpeta de cowsay.
# ------------------------------------------------------------
elegir_cowfile() {
    local cowfile

    # Comprobamos que exista el directorio donde están los cowfiles
    if [ ! -d "$DIRECTORIO_COWS" ]; then
        echo "ERROR: no existe el directorio $DIRECTORIO_COWS"
        log_msg "ERROR: no existe el directorio de cowfiles"
        exit 1
    fi

    # Buscamos un archivo .cow aleatorio dentro del directorio
    cowfile=$(find "$DIRECTORIO_COWS" -type f -name "*.cow" | shuf -n 1)

    # Si no se encuentra ningún fichero, se informa del error
    if [ -z "$cowfile" ]; then
        echo "ERROR: no se encontró ningún fichero .cow"
        log_msg "ERROR: no se encontró ningún cowfile"
        exit 1
    fi

    # Devolvemos solo el nombre del fichero sin ruta ni extensión
    basename "$cowfile" .cow
}

# ------------------------------------------------------------
# Tratamiento de parámetros con getopts
# Objetivo:
# Analizar las opciones introducidas por el usuario al ejecutar
# el script.
# ------------------------------------------------------------
while getopts ":m:l:h" opt; do
    case "$opt" in
        # Opción -m: forzar el saludo
        m) SALUDO_FORZADO="$OPTARG" ;;

        # Opción -l: indicar archivo de log personalizado
        l) LOG_FILE="$OPTARG" ;;

        # Opción -h: mostrar ayuda y salir
        h)
            mostrar_ayuda
            exit 0
            ;;

        # Opción no válida
        \?)
            echo "ERROR: opción no válida: -$OPTARG"
            mostrar_ayuda
            exit 1
            ;;

        # Opción que requiere argumento y no lo tiene
        :)
            echo "ERROR: la opción -$OPTARG requiere un valor"
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------
# Programa principal
# Objetivo:
# Coordinar la ejecución general del script.
# ------------------------------------------------------------

# Comprobamos que cowsay esté instalado
comprobar_cowsay

# Obtenemos el saludo que se va a mostrar
saludo=$(obtener_saludo)

# Elegimos el cowfile aleatorio
cowfile=$(elegir_cowfile)

# Guardamos en el log la información de la ejecución
log_msg "Saludo seleccionado: $saludo"
log_msg "Cowfile seleccionado: $cowfile"

# Mostramos el saludo final con cowsay
cowsay -f "$cowfile" "$saludo"

