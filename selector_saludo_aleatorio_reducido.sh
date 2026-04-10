#!/bin/bash

hora=$(date +%H)

if [ "$hora" -lt 12 ]; then
    saludo="Buenos días"
elif [ "$hora" -lt 20 ]; then
    saludo="Buenas tardes"
else
    saludo="Buenas noches"
fi

cow=$(cowsay -l | sed '1d' | xargs -n1 | shuf -n1)
cowsay -f "$cow" "$saludo"
