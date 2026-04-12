#!/bin/bash

# ==========================================
# Script: mayormenorsuma.sh
# Recibe varios números por parámetro y
# calcula el mayor, el menor y la suma.
# ==========================================

# Nombre del archivo de logs
LOGFILE="mayormenorsuma.log"

# ------------------------------------------
# Función: log
# Guarda en el fichero de log el mensaje que
# se le pase como parámetro, añadiendo fecha y hora.
# ------------------------------------------
log() {
    fecha=$(date "+%Y-%m-%d %H:%M:%S")   # Guarda fecha actual en una variable
    echo "[$fecha] $1" >> "$LOGFILE"     # Añade el mensaje al final del fichero log
}

# ------------------------------------------
# Función: mostrar_uso
# Muestra por pantalla cómo se debe ejecutar
# el script y la opción de ayuda.
# ------------------------------------------
mostrar_uso() {
    echo "Uso: $0 num1 num2 num3 ..."
    echo "Ejemplo: $0 4 9 2 7"
    echo "Ayuda: $0 -h | $0 --help"
}

# ------------------------------------------
# Función: es_entero
# Comprueba si el valor recibido es un número entero.
# Si es válido devuelve 0.
# Si no es válido devuelve 1.
#
# return 0 significa 'todo correcto'
# return 1 significa 'error'
# ------------------------------------------
es_entero() {
    case "$1" in
        ''|*[!0-9-]*|-)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

# ------------------------------------------
# Función: calcular
# Recorre todos los números recibidos y calcula:
# - el mayor
# - el menor
# - la suma total
# ------------------------------------------
calcular() {
    # Al principio suponemos que el primer número
    # es a la vez el mayor y el menor
    mayor=$1
    menor=$1

    # Inicializamos la suma en 0
    suma=0

    # Recorremos todos los parámetros del script
    # "$@" trata cada parámetro por separado
    for num in "$@"
    do
        # Vamos acumulando la suma
        suma=$((suma + num))

        # Si el número actual es mayor que "mayor",
        # actualizamos la variable
        if [ "$num" -gt "$mayor" ]; then
            mayor=$num
        fi

        # Si el número actual es menor que "menor",
        # actualizamos la variable
        if [ "$num" -lt "$menor" ]; then
            menor=$num
        fi
    done
}

# ==========================================
# Comienza la ejecución del script
# ==========================================

# Guardamos en el log que el script ha comenzado
log "Inicio del script"

# Si el usuario pide ayuda con -h o --help,
# se muestra el modo de uso y termina el script
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    mostrar_uso
    log "Se mostró la ayuda"
    exit 0
fi

# Comprobamos si el usuario no ha pasado parámetros
# $# indica cuántos parámetros se han recibido
if [ $# -eq 0 ]; then
    echo "Error: debes pasar al menos un número."
    mostrar_uso
    log "Error: no se recibieron parámetros"
    exit 1
fi

# Validamos todos los parámetros para comprobar que son enteros
for param in "$@"
do
    if ! es_entero "$param"; then
        echo "Error: '$param' no es un número entero válido."
        log "Error: parámetro no válido -> $param"
        exit 1
    fi
done

# Si todos los parámetros son correctos,
# llamamos a la función que hace los cálculos
calcular "$@"

# Mostramos los resultados por pantalla
echo "Mayor: $mayor"
echo "Menor: $menor"
echo "Suma: $suma"

# Guardamos también el resultado final en el log
log "Resultado -> Mayor: $mayor | Menor: $menor | Suma: $suma"

# Guardamos en el log que el script ha terminado
log "Fin del script"

# Finalizamos correctamente
exit 0