#!/bin/bash
# =============================================================
# crear2.sh - Crea un fichero con el nombre y tamaño indicados.
# Si el fichero ya existe, prueba con nombre1, nombre2, ... nombre9.
# Si también existe nombre9, no crea nada.
# =============================================================

LOG_FILE="crear2.log"

log() {
    local nivel="$1"
    local mensaje="$2"
    local fecha
    fecha=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$fecha] [$nivel] $mensaje" | tee -a "$LOG_FILE"
}

mostrar_ayuda() {
    echo "Uso: $0 [nombre] [tamaño_KB]"
    echo "  $0 -h                Muestra esta ayuda"
    echo "  $0 nombre tamano     Crea el fichero con ese nombre y tamaño"
    echo "  $0 nombre            Crea el fichero con 1024 KB"
    echo "  $0                   Crea 'fichero_vacio' con 1024 KB"
    echo "Si el fichero ya existe, probará con nombre1, nombre2... hasta nombre9"
    exit 0
}

crear_fichero() {
    local nombre="$1"
    local tamanio="$2"

    log "INFO" "Creando fichero '$nombre' con tamaño ${tamanio} KB..."
    dd if=/dev/zero of="$nombre" bs=1024 count="$tamanio" 2>/dev/null

    if [ $? -eq 0 ]; then
        log "INFO" "Fichero '$nombre' creado correctamente (${tamanio} KB)"
    else
        log "ERROR" "No se pudo crear el fichero '$nombre'"
        exit 1
    fi
}

buscar_nombre_libre() {
    local base="$1"
    local nombre_final="$base"

    if [ ! -e "$base" ]; then
        echo "$nombre_final"
        return
    fi

    log "INFO" "El fichero '$base' ya existe"
    echo "El fichero '$base' ya existe"

    for i in 1 2 3 4 5 6 7 8 9
    do
        if [ ! -e "${base}$i" ]; then
            nombre_final="${base}$i"
            log "INFO" "Se usará el nombre '$nombre_final'"
            echo "$nombre_final"
            return
        fi
    done

    log "ERROR" "Ya existen '$base' y todas sus versiones hasta '${base}9'"
    echo "ERROR: Ya existen '$base' y todas sus versiones hasta '${base}9'"
    exit 1
}

log "INFO" "===== INICIO DEL SCRIPT ====="
log "INFO" "Número de parámetros recibidos: $#"

if [ "$1" = "-h" ]; then
    mostrar_ayuda
fi

if [ $# -eq 0 ]; then
    NOMBRE="fichero_vacio"
    TAMANIO=1024
    log "INFO" "Sin parámetros -> nombre='fichero_vacio', tamaño=1024 KB"
elif [ $# -eq 1 ]; then
    NOMBRE="$1"
    TAMANIO=1024
    log "INFO" "Solo nombre -> nombre='$1', tamaño=1024 KB"
elif [ $# -eq 2 ]; then
    NOMBRE="$1"
    TAMANIO="$2"
    log "INFO" "Nombre y tamaño -> nombre='$1', tamaño=$2 KB"

    if ! [[ "$TAMANIO" =~ ^[0-9]+$ ]]; then
        log "ERROR" "El tamaño '$TAMANIO' no es un número válido"
        exit 1
    fi
else
    log "ERROR" "Demasiados parámetros. Usa '$0 -h' para ver la ayuda."
    exit 1
fi

NOMBRE_FINAL=$(buscar_nombre_libre "$NOMBRE")
crear_fichero "$NOMBRE_FINAL" "$TAMANIO"

log "INFO" "===== FIN DEL SCRIPT ====="
exit 0
