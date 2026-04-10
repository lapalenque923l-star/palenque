#!/bin/bash

dir=${1:-.}

for archivo in "$dir"/*; do
    [ -e "$archivo" ] || continue

    nombre=$(basename "$archivo")

    if [ -d "$archivo" ]; then
        echo "$nombre/"
    elif [ -f "$archivo" ] && [ -x "$archivo" ]; then
        echo "$nombre*"
    else
        echo "$nombre"
    fi
done