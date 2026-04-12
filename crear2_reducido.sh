#!/bin/bash

BASE=${1:-fichero_vacio}
TAMANIO=${2:-1024}
NOMBRE="$BASE"

[ "$1" = "-h" ] && echo "Uso: $0 [nombre] [tamaño_KB]" && exit 0
! [[ "$TAMANIO" =~ ^[0-9]+$ ]] && echo "ERROR: tamaño no válido" && exit 1

if [ -e "$BASE" ]; then
    NOMBRE=""
    for i in 1 2 3 4 5 6 7 8 9; do
        [ ! -e "${BASE}$i" ] && NOMBRE="${BASE}$i" && break
    done
    [ -z "$NOMBRE" ] && echo "ERROR: ya existen '$BASE' y '${BASE}1'...'${BASE}9'" && exit 1
fi

dd if=/dev/zero of="$NOMBRE" bs=1024 count="$TAMANIO" 2>/dev/null
echo "Fichero '$NOMBRE' creado correctamente"
