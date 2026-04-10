#!/bin/bash

[ "$1" = "-h" ] && echo "Uso: $0 [nombre] [tamaño_KB]" && exit 0

NOMBRE=${1:-fichero_vacio}
TAMANIO=${2:-1024}

dd if=/dev/zero of="$NOMBRE" bs=1024 count="$TAMANIO" 2>/dev/null
