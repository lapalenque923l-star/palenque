#!/bin/bash
# =============================================================
# crear2_completo_final.sh
# Crea un fichero con el nombre y tamaño indicados.
# Si el fichero ya existe, prueba con nombre1, nombre2... hasta nombre9.
# Si también existe nombre9, avisa y no crea nada.
# =============================================================

LOG_FILE="crear2.log"

# ----------- FUNCIÓN DE LOG -----------
log() {
    local nivel="$1"
    local mensaje="$2"
    local fecha
    fecha=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$fecha] [$nivel] $mensaje" | tee -a "$LOG_FILE"
}

# ----------- FUNCIÓN DE AYUDA -----------
mostrar_ayuda() {
    echo "Uso: $0 [nombre] [tamaño_KB]"
    echo "  $0 -h                Muestra esta ayuda"
    echo "  $0 nombre tamano     Crea el fichero con ese nombre y tamaño"
    echo "  $0 nombre            Crea el fichero con 1024 KB"
    echo "  $0                   Crea 'fichero_vacio' con 1024 KB"
    echo "Si el fichero ya existe, prueba con nombre1...nombre9"
    exit 0
}

# ----------- FUNCIÓN PARA CREAR EL FICHERO -----------
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

# =============================================================
# BLOQUE PRINCIPAL
# =============================================================

log "INFO" "===== INICIO DEL SCRIPT ====="
log "INFO" "Número de parámetros recibidos: $#"

# Mostrar ayuda si se ejecuta con -h
if [ "$1" = "-h" ]; then
    mostrar_ayuda
fi

# Tratamiento de parámetros
if [ $# -eq 0 ]; then
    BASE="fichero_vacio"
    TAMANIO=1024
    log "INFO" "Sin parámetros -> nombre='fichero_vacio', tamaño=1024 KB"
elif [ $# -eq 1 ]; then
    BASE="$1"
    TAMANIO=1024
    log "INFO" "Solo nombre -> nombre='$1', tamaño=1024 KB"
elif [ $# -eq 2 ]; then
    BASE="$1"
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

# BASE es el nombre original y no cambia nunca
# NOMBRE_FINAL será el nombre que realmente se use
NOMBRE_FINAL="$BASE"

# Si ya existe el nombre base, buscar un nombre libre entre 1 y 9
if [ -e "$BASE" ]; then
    log "INFO" "El fichero '$BASE' ya existe"
    echo "El fichero '$BASE' ya existe"

    NOMBRE_FINAL=""

    for i in 1 2 3 4 5 6 7 8 9
    do
        if [ ! -e "${BASE}$i" ]; then
            NOMBRE_FINAL="${BASE}$i"
            log "INFO" "Se usará el nombre '$NOMBRE_FINAL'"
            break
        fi
    done

    # Si sigue vacío, es que existen base, base1, ..., base9
    if [ -z "$NOMBRE_FINAL" ]; then
        log "ERROR" "Ya existen '$BASE' y todas sus versiones hasta '${BASE}9'"
        echo "ERROR: Ya existen '$BASE' y todas sus versiones hasta '${BASE}9'"
        exit 1
    fi
fi

# Crear el fichero con el nombre final decidido
crear_fichero "$NOMBRE_FINAL" "$TAMANIO"

log "INFO" "===== FIN DEL SCRIPT ====="
exit 0
