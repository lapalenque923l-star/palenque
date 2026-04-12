#!/bin/bash

#########################################################################
# Script: agenda.sh
# Permite el mantenimiento de una agenda de contactos mediante un menú.
#
# Opciones del menú:
#   a) Añadir registro
#   b) Eliminar registro (por nombre)
#   c) Buscar (por nombre, dirección o teléfono)
#   d) Listar
#   e) Ordenar alfabéticamente
#   f) Borrar toda la agenda
#   g) Modificar registro con sed
#   h) Salir
#
# Uso:
#   ./agenda.sh
#   ./agenda.sh agenda.txt
#   ./agenda.sh -h
#   ./agenda.sh --help
#########################################################################

# Archivo de agenda por defecto
AGENDA="agenda.txt"

# Archivo de log
LOGFILE="agenda.log"

# Script que añade registros
ADD_SCRIPT="./addagenda.sh"

#########################################################################
# Función: mostrar_ayuda
# Muestra cómo se usa el script.
#########################################################################
mostrar_ayuda() {
    echo "Uso: $0 [archivo_agenda]"
    echo
    echo "Este script permite gestionar una agenda con un menú."
    echo
    echo "Opciones del menú:"
    echo "  a) Añadir registro"
    echo "  b) Eliminar registro"
    echo "  c) Buscar"
    echo "  d) Listar"
    echo "  e) Ordenar"
    echo "  f) Borrar agenda"
    echo "  g) Modificar registro"
    echo "  h) Salir"
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
# Función: comprobar_agenda
# Comprueba que el archivo agenda exista o pueda crearse.
#########################################################################
comprobar_agenda() {
    touch "$AGENDA" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: no se puede acceder al archivo $AGENDA"
        log_error "No se puede acceder al archivo $AGENDA"
        exit 1
    fi
}

#########################################################################
# Función: anadir_registro
# Llama al script addagenda.sh para añadir uno o varios registros.
#########################################################################
anadir_registro() {
    log_info "Se seleccionó la opción Añadir"

    if [ ! -x "$ADD_SCRIPT" ]; then
        echo "Error: no se encuentra o no se puede ejecutar $ADD_SCRIPT"
        log_error "No se puede ejecutar $ADD_SCRIPT"
        return
    fi

    "$ADD_SCRIPT" "$AGENDA"
}

#########################################################################
# Función: eliminar_registro
# Elimina los registros cuyo nombre coincida con el introducido.
# Se toma el nombre como primer campo de la línea.
#########################################################################
eliminar_registro() {
    read -p "Introduce el nombre a eliminar: " nombre

    if [ ! -f "$AGENDA" ] || [ ! -s "$AGENDA" ]; then
        echo "La agenda no existe o está vacía."
        log_error "Intento de eliminar en agenda vacía o inexistente"
        return
    fi

    # Se crea un archivo temporal sin las líneas del nombre buscado
    grep -v "^$nombre[[:space:]]" "$AGENDA" > .agenda_tmp

    if [ $? -ne 0 ]; then
        # grep puede devolver código distinto de 0 si no encuentra coincidencias,
        # pero el archivo temporal igualmente puede haberse creado.
        # Por eso comprobamos después el mv.
        true
    fi

    mv .agenda_tmp "$AGENDA"
    if [ $? -eq 0 ]; then
        echo "Registro(s) eliminado(s) si existían coincidencias."
        log_info "Eliminación realizada para el nombre: $nombre"
    else
        echo "Error al eliminar el registro."
        log_error "Fallo al eliminar el nombre: $nombre"
    fi
}

#########################################################################
# Función: buscar_registro
#   Busca texto en cualquier campo: nombre, dirección o teléfono.
#########################################################################
buscar_registro() {
    read -p "Introduce el texto a buscar: " texto

    if [ ! -f "$AGENDA" ] || [ ! -s "$AGENDA" ]; then
        echo "La agenda no existe o está vacía."
        log_error "Intento de búsqueda en agenda vacía o inexistente"
        return
    fi

    echo "Resultados de la búsqueda:"
    grep -i "$texto" "$AGENDA"

    if [ $? -eq 0 ]; then
        log_info "Búsqueda realizada con texto: $texto"
    else
        echo "No se encontraron coincidencias."
        log_info "Búsqueda sin resultados para: $texto"
    fi
}

#########################################################################
# Función: listar_agenda
# Muestra todo el contenido del archivo agenda.
#########################################################################
listar_agenda() {
    if [ ! -f "$AGENDA" ] || [ ! -s "$AGENDA" ]; then
        echo "La agenda no existe o está vacía."
        log_info "Listado solicitado sobre agenda vacía o inexistente"
        return
    fi

    echo "Contenido de la agenda:"
    cat "$AGENDA"
    log_info "Listado completo de la agenda"
}

#########################################################################
# Función: ordenar_agenda
# Ordena alfabéticamente el archivo agenda.
#########################################################################
ordenar_agenda() {
    if [ ! -f "$AGENDA" ] || [ ! -s "$AGENDA" ]; then
        echo "La agenda no existe o está vacía."
        log_error "Intento de ordenar agenda vacía o inexistente"
        return
    fi

    sort "$AGENDA" -o "$AGENDA"
    if [ $? -eq 0 ]; then
        echo "Agenda ordenada correctamente."
        log_info "Agenda ordenada alfabéticamente"
    else
        echo "Error al ordenar la agenda."
        log_error "Fallo al ordenar la agenda"
    fi
}

#########################################################################
# Función: borrar_agenda
#   Borra todo el contenido del archivo agenda.
#########################################################################
borrar_agenda() {
    if [ ! -f "$AGENDA" ]; then
        echo "La agenda no existe."
        log_error "Intento de borrar una agenda inexistente"
        return
    fi

    read -p "¿Seguro que quieres borrar toda la agenda? (s/n): " respuesta

    case "$respuesta" in
        s|S)
            > "$AGENDA"
            if [ $? -eq 0 ]; then
                echo "Agenda borrada correctamente."
                log_info "Se borró todo el contenido de la agenda"
            else
                echo "Error al borrar la agenda."
                log_error "Fallo al borrar la agenda"
            fi
            ;;
        *)
            echo "Operación cancelada."
            log_info "Borrado de agenda cancelado por el usuario"
            ;;
    esac
}

#########################################################################
# Función: modificar_registro
#   Pide un texto a buscar y otro de reemplazo, y modifica el archivo usando sed.
#   Reemplaza todas las apariciones en el fichero.
#########################################################################
modificar_registro() {
    if [ ! -f "$AGENDA" ] || [ ! -s "$AGENDA" ]; then
        echo "La agenda no existe o está vacía."
        log_error "Intento de modificar agenda vacía o inexistente"
        return
    fi

    read -p "Introduce el dato a buscar: " buscar
    read -p "Introduce el dato de reemplazo: " reemplazo

    sed -i "s/$buscar/$reemplazo/g" "$AGENDA"

    if [ $? -eq 0 ]; then
        echo "Modificación realizada correctamente."
        log_info "Se reemplazó '$buscar' por '$reemplazo'"
    else
        echo "Error al modificar el archivo."
        log_error "Fallo en la modificación con sed: '$buscar' -> '$reemplazo'"
    fi
}

#########################################################################
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
# Comprobación inicial del archivo
#########################################################################
comprobar_agenda
log_info "Inicio de agenda.sh usando el archivo $AGENDA"

#########################################################################
# Menú principal
#########################################################################
while true
do
    echo
    echo "=============================="
    echo "           AGENDA             "
    echo "=============================="
    echo "a) Añadir registro"
    echo "b) Eliminar registro"
    echo "c) Buscar"
    echo "d) Listar"
    echo "e) Ordenar"
    echo "f) Borrar agenda"
    echo "g) Modificar registro"
    echo "h) Salir"
    echo "=============================="

    read -p "Selecciona una opción: " opcion

    case "$opcion" in
        a) anadir_registro ;;
        b) eliminar_registro ;;
        c) buscar_registro ;;
        d) listar_agenda ;;
        e) ordenar_agenda ;;
        f) borrar_agenda ;;
        g) modificar_registro ;;
        h)
            echo "Hasta luego."
            log_info "Salida normal del programa"
            exit 0
            ;;
        *)
            echo "Opción no válida."
            log_error "Opción no válida introducida: $opcion"
            ;;
    esac
done
