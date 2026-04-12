#!/bin/bash

#########################################################################
# Script: addagenda.sh
#   Añade registros a un archivo de agenda.
#   Cada registro tendrá: nombre, dirección y teléfono, separados por tabuladores.
#   El programa termina cuando se escribe FIN como nombre.
# Uso:
#   ./addagenda.sh
#   ./addagenda.sh agenda.txt
#   ./addagenda.sh -h
#   ./addagenda.sh --help
###############################################################################

# Archivo de agenda por defecto
AGENDA="agenda.txt"

# Archivo de log
LOGFILE="agenda.log"

#########################################################################
# Función: mostrar_ayuda
# Muestra cómo se usa el script.
#########################################################################
mostrar_ayuda() {
    echo "Uso: $0 [archivo_agenda]"
    echo
    echo "Este script añade registros a una agenda."
    echo "Cada registro contiene: nombre, dirección y teléfono."
    echo "Los campos se guardan en una sola línea, separados por tabuladores."
    echo "Para terminar la entrada de datos, escribe FIN como nombre."
}
#########################################################################
# Función: log_info
# Guarda mensajes informativos en el fichero de log.
#########################################################################
log_info() {
    fecha=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$fecha [INFO] $1" >> "$LOGFILE"
}

#########################################################################
# Función: log_error
# Guarda mensajes de error en el fichero de log.
#########################################################################
log_error() {
    fecha=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$fecha [ERROR] $1" >> "$LOGFILE"
}

#########################################################################
# Función: salir_con_error
# Muestra un error por pantalla, lo guarda en el log y termina el script.
#########################################################################
salir_con_error() {
    echo "Error: $1"
    log_error "$1"
    exit 1
}

########################################################################
# Tratamiento de parámetros
# Solo se permite:
#   - ningún parámetro
#   - un nombre de archivo
#   - -h o --help
#########################################################################
if [ $# -gt 1 ]; then
    mostrar_ayuda
    exit 1
fi

if [ $# -eq 1 ]; then
    case "$1" in
        -h|--help)
            mostrar_ayuda
            exit 0
            ;;
        *)
            AGENDA="$1"
            ;;
    esac
fi
#########################################################################
# Comprobación del archivo de agenda
# Si no existe, se intenta crear.
#########################################################################
touch "$AGENDA" 2>/dev/null
if [ $? -ne 0 ]; then
    salir_con_error "No se puede crear o escribir en el archivo $AGENDA"
fi

log_info "Inicio de addagenda.sh usando el archivo $AGENDA"

#########################################################################
# Bucle principal
# Pide datos hasta que el nombre sea FIN
#########################################################################
while true
do
    read -p "Nombre (FIN para terminar): " nombre

    # Si el usuario escribe FIN, termina el programa
    if [ "$nombre" = "FIN" ]; then
        log_info "Fin de la introducción de datos"
        echo "Fin del programa."
        break
    fi

    # Comprobación básica: el nombre no debe estar vacío
    if [ -z "$nombre" ]; then
        echo "El nombre no puede estar vacío."
        log_error "Se intentó añadir un registro con nombre vacío"
        continue
    fi

    read -p "Dirección: " direccion
    read -p "Teléfono: " telefono

    # Guardar el registro en una sola línea separado por tabuladores
    echo -e "$nombre\t$direccion\t$telefono" >> "$AGENDA"

    if [ $? -eq 0 ]; then
        echo "Registro añadido correctamente."
        log_info "Registro añadido: $nombre"
    else
        salir_con_error "No se pudo guardar el registro en $AGENDA"
    fi
done

exit 0

