#!/bin/bash

N=${1:-fichero_vacio}
T=${2:-1024}
F=$N

[ "$1" = "-h" ] && echo "Uso: $0 [nombre] [tamaño_KB]" && exit 0
! [[ "$T" =~ ^[0-9]+$ ]] && echo "ERROR: tamaño no válido" && exit 1

[ -e "$F" ] && for i in 1 2 3 4 5 6 7 8 9
do
    [ ! -e "${N}$i" ] && F="${N}$i" && break
done

[ -e "$F" ] && echo "ERROR: no se puede crear el fichero" && exit 1

dd if=/dev/zero of="$F" bs=1024 count="$T" 2>/dev/null
echo "Fichero '$F' creado correctamente"
