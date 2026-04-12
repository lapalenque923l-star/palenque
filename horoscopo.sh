#!/bin/bash

# =========================================================
# Script: horoscopo.sh
#   Este script pide o recibe como parámetro un año de nacimiento
#   y muestra el animal correspondiente del horóscopo chino.
# =========================================================

# Fichero donde se guardan los logs
LOGFILE="horoscopo.log"

# Variable donde guardamos el año
ANIO=""

# ---------------------------------------------------------
# Función: mostrar_ayuda
# # Cuando el usuario escribe -h o --help
# ---------------------------------------------------------
mostrar_ayuda() {
    echo "Uso: $0 [OPCIONES]"
    echo
    echo "Opciones:"
    echo "  -a, --anio NUMERO   Indica el año de nacimiento (4 cifras)"
    echo "  -h, --help          Muestra esta ayuda"
    echo
    echo "Ejemplos:"
    echo "  $0"
    echo "  $0 -a 1965"
    echo "  $0 --anio 2000"
}

# ---------------------------------------------------------
# Función: log_info
# Guarda un mensaje informativo en el fichero de log.
# Añade fecha, hora, tipo de mensaje y texto recibido.
# ---------------------------------------------------------
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> "$LOGFILE"
}

# ---------------------------------------------------------
# Función: log_error
# Guarda un mensaje de error en el fichero de log.
# Deja constancia si el usuario escribe mal un parámetro o año mal
# ---------------------------------------------------------
log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >> "$LOGFILE"
}

# ---------------------------------------------------------
# Función: pedir_anio
# Pide al usuario el año por teclado.
# Se usa si el usuario no ha pasado el año con -a o --anio
# ---------------------------------------------------------
pedir_anio() {
    read -p "Introduce tu año de nacimiento (4 cifras): " ANIO
}

# ---------------------------------------------------------
# Función: validar_anio
# Comprueba si el año introducido es correcto.
# Validaciones:
#   1. Que no esté vacío
#   2. Que tenga exactamente 4 cifras
# Si hay error:
#   - Muestra mensaje por pantalla
#   - Guarda el error en el log
#   - Finaliza el script con exit 1
# ---------------------------------------------------------
validar_anio() {
    # Comprobamos si está vacío
    if [ -z "$ANIO" ]; then
        echo "Error: no se ha indicado ningún año."
        log_error "No se indicó ningún año"
        exit 1
    fi

    # Comprobamos si son exactamente 4 números
    if ! [[ "$ANIO" =~ ^[0-9]{4}$ ]]; then
        echo "Error: el año debe tener exactamente 4 cifras."
        log_error "Año no válido: $ANIO"
        exit 1
    fi
}

# ---------------------------------------------------------
# Función: obtener_animal
# Calcula el resto de dividir el año entre 12.
# Explicación:
#   En Bash, el operador % devuelve el resto de una división.
#   Ese resto será un número entre 0 y 11.
#   Según ese número, se asigna un animal con case.
# Ejemplo:
#   1965 % 12 = 9
#   9 corresponde a La Serpiente
# ---------------------------------------------------------
obtener_animal() {
    RESTO=$((ANIO % 12))

    case $RESTO in
        0) ANIMAL="El Mono" ;;
        1) ANIMAL="El Gallo" ;;
        2) ANIMAL="El Perro" ;;
        3) ANIMAL="El Cerdo" ;;
        4) ANIMAL="La Rata" ;;
        5) ANIMAL="El Buey" ;;
        6) ANIMAL="El Tigre" ;;
        7) ANIMAL="El Conejo" ;;
        8) ANIMAL="El Dragón" ;;
        9) ANIMAL="La Serpiente" ;;
        10) ANIMAL="El Caballo" ;;
        11) ANIMAL="La Cabra" ;;
        *)
            # Este caso no debería ocurrir nunca,
            # porque el resto de dividir entre 12 va de 0 a 11.
            echo "Error inesperado al calcular el animal."
            log_error "Resto inesperado: $RESTO"
            exit 1
            ;;
    esac
}

# ---------------------------------------------------------
# Función: mostrar_resultado
# Muestra el resultado final por pantalla y lo guarda en el log.
# ---------------------------------------------------------
mostrar_resultado() {
    echo "Si naciste en $ANIO te corresponde $ANIMAL según el horóscopo chino."
    log_info "Consulta correcta para el año $ANIO: $ANIMAL"
}

# =========================================================
# TRATAMIENTO DE PARÁMETROS
# =========================================================
# Aquí usamos:
#   while [ $# -gt 0 ]
#
# Significa: mientras queden parámetros por procesar...
# $#  -> número de parámetros que quedan
# $1  -> primer parámetro actual
# shift -> elimina el primer parámetro y desplaza los demás
# =========================================================
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            mostrar_ayuda
            exit 0
            ;;

        -a|--anio)
            # Si el usuario pone -a o --anio,
            # el siguiente parámetro debería ser el año.
            shift

            # Si después de hacer shift no hay nada,
            # significa que falta el valor del año.
            if [ -z "$1" ]; then
                echo "Error: debes indicar un año después de -a o --anio."
                log_error "Falta valor para el parámetro de año"
                exit 1
            fi

            ANIO="$1"
            ;;

        *)
            # Si entra aquí, el parámetro no es válido
            echo "Error: parámetro no válido: $1"
            log_error "Parámetro no válido: $1"
            mostrar_ayuda
            exit 1
            ;;
    esac

    # Pasamos al siguiente parámetro
    shift
done

# =========================================================
# PROGRAMA PRINCIPAL
# =========================================================

# Si el usuario no ha pasado el año por parámetro, se pide por teclado.
if [ -z "$ANIO" ]; then
    pedir_anio
fi

# Validamos el dato introducido o recibido
validar_anio

# Calculamos qué animal corresponde
obtener_animal

# Mostramos el resultado final
mostrar_resultado
