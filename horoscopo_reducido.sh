#!/bin/bash

read -p "Introduce tu año de nacimiento (4 cifras): " anio

if ! [[ "$anio" =~ ^[0-9]{4}$ ]]; then
    echo "Error: debes introducir un año de 4 cifras."
    exit 1
fi

resto=$((anio % 12))

case $resto in
    0) animal="El Mono" ;;
    1) animal="El Gallo" ;;
    2) animal="El Perro" ;;
    3) animal="El Cerdo" ;;
    4) animal="La Rata" ;;
    5) animal="El Buey" ;;
    6) animal="El Tigre" ;;
    7) animal="El Conejo" ;;
    8) animal="El Dragón" ;;
    9) animal="La Serpiente" ;;
    10) animal="El Caballo" ;;
    11) animal="La Cabra" ;;
esac

echo "Si naciste en $anio te corresponde $animal según el horóscopo chino."
