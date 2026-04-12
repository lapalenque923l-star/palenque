#!/bin/bash

if [ "$1" = "-h" ]; then
    echo "Uso: $0 num1 num2 num3 ..."
    exit 0
fi

mayor=$1
menor=$1
suma=0

for n in "$@"
do
    suma=$((suma + n))

    if [ "$n" -gt "$mayor" ]; then
        mayor=$n
    fi

    if [ "$n" -lt "$menor" ]; then
        menor=$n
    fi
done

echo "Mayor: $mayor"
echo "Menor: $menor"
echo "Suma: $suma"