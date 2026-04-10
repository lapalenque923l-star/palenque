#!/bin/bash
# =============================================================
# crear.sh - Crea un fichero con el nombre y tamaño indicados
# Uso:
#   ./crear.sh -h                    -> muestra esta ayuda
#   ./crear.sh <nombre> <tamaño_KB>  -> crea fichero con nombre y tamaño
#   ./crear.sh <nombre>              -> crea fichero con 1024 KB
#   ./crear.sh                       -> crea 'fichero_vacio' con 1024 KB
# =============================================================

LOG_FILE="crear.log"

# ----------- FUNCIÓN DE LOG -----------
# Parámetros:
#   - $1: nivel del mensaje (INFO, ERROR)
#   - $2: mensaje a registrar
# Escribe en pantalla Y en el fichero de log a la vez (tee -a)
log() {
    local nivel="$1"
    local mensaje="$2"
    local fecha
    fecha=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$fecha] [$nivel] $mensaje" | tee -a "$LOG_FILE"
}

# ----------- FUNCIÓN DE AYUDA -----------
# Se llama cuando el usuario ejecuta: ./crear.sh -h
# cat << EOF imprime todo el texto hasta encontrar EOF
mostrar_ayuda() {
    cat << EOF
Uso: $0 [OPCIÓN] [nombre] [tamaño_KB]

Opciones:
  -h            Muestra esta ayuda y termina

Modos de uso:
  $0 <nombre> <tamaño_KB>   Crea el fichero 'nombre' con el tamaño indicado en KB
  $0 <nombre>               Crea el fichero 'nombre' con 1024 KB (tamaño por defecto)
  $0                        Crea el fichero 'fichero_vacio' con 1024 KB

Ejemplos:
  $0 aguado 546    -> crea fichero 'aguado' de 546 KB
  $0 panadero      -> crea fichero 'panadero' de 1024 KB
  $0               -> crea fichero 'fichero_vacio' de 1024 KB
EOF
    exit 0
}

# ----------- FUNCIÓN: CREAR FICHERO -----------
# Parámetros:
#   - $1: nombre del fichero a crear
#   - $2: tamaño del fichero en kilobytes
crear_fichero() {
    local nombre="$1"
    local tamanio="$2"

    log "INFO" "Creando fichero '$nombre' con tamaño ${tamanio} KB..."

    # dd crea el fichero con el tamaño exacto:
    #   if=/dev/zero   -> fuente de bytes nulos
    #   of="$nombre"   -> nombre del fichero de salida
    #   bs=1024        -> tamaño de bloque = 1 KB
    #   count=$tamanio -> número de bloques (= KB totales)
    #   2>/dev/null    -> oculta los mensajes de progreso de dd
    dd if=/dev/zero of="$nombre" bs=1024 count="$tamanio" 2>/dev/null

    # $? es el código de salida del último comando (0 = éxito, otro = error)
    if [ $? -eq 0 ]; then
        log "INFO" "Fichero '$nombre' creado correctamente (${tamanio} KB)"
    else
        log "ERROR" "No se pudo crear el fichero '$nombre'"
        exit 1
    fi
}

# =============================================================
# BLOQUE PRINCIPAL - Tratamiento de parámetros
# Comprobamos primero si el primer parámetro ($1) es -h
# =============================================================

log "INFO" "===== INICIO DEL SCRIPT ====="
log "INFO" "Número de parámetros recibidos: $#"

# AYUDA: si el primer parámetro es -h, mostramos ayuda y salimos
if [ "$1" = "-h" ]; then
    mostrar_ayuda
fi

# Analizamos el número de parámetros con $#
if [ $# -eq 0 ]; then
    # CASO 1: SIN PARÁMETROS -> nombre por defecto y tamaño por defecto
    log "INFO" "Sin parámetros -> nombre='fichero_vacio', tamaño=1024 KB"
    NOMBRE="fichero_vacio"
    TAMANIO=1024

elif [ $# -eq 1 ]; then
    # CASO 2: SOLO NOMBRE -> tamaño por defecto (1024 KB)
    log "INFO" "Solo nombre -> nombre='$1', tamaño=1024 KB"
    NOMBRE="$1"
    TAMANIO=1024

elif [ $# -eq 2 ]; then
    # CASO 3: NOMBRE Y TAMAÑO -> usamos los dos parámetros
    log "INFO" "Nombre y tamaño -> nombre='$1', tamaño=$2 KB"
    NOMBRE="$1"
    TAMANIO="$2"

    # Verificamos que el tamaño sea un número entero positivo
    # =~ comprueba si la variable encaja con la expresión regular ^[0-9]+$
    # ^ significa inicio, [0-9]+ uno o más dígitos, $ significa fin
    if ! [[ "$TAMANIO" =~ ^[0-9]+$ ]]; then
        log "ERROR" "El tamaño '$TAMANIO' no es un número válido (solo enteros positivos)"
        exit 1
    fi

else
    # CASO 4: MÁS DE 2 PARÁMETROS -> error, demasiados argumentos
    log "ERROR" "Demasiados parámetros. Usa '$0 -h' para ver la ayuda."
    exit 1
fi

# Comprobación de seguridad: no sobreescribir un fichero existente
if [ -e "$NOMBRE" ]; then
    log "ERROR" "Ya existe un fichero llamado '$NOMBRE'. Script detenido."
    exit 1
fi

# Llamamos a la función para crear el fichero
crear_fichero "$NOMBRE" "$TAMANIO"

log "INFO" "===== FIN DEL SCRIPT ====="
exit 0