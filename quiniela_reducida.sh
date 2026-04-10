#!/bin/bash

for ((i=1; i<=14; i++)); do
    r=$((RANDOM % 3))

    if [ "$r" -eq 0 ]; then
        res="1"
    elif [ "$r" -eq 1 ]; then
        res="X"
    else
        res="2"
    fi

    printf "%2d.- %s\n" "$i" "$res"
done