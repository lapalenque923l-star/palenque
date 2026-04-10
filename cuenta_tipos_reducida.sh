#!/bin/bash

dir=${1:-.}
[ -d "$dir" ] || exit 1

ct=0; cdv=0; cd=0; ce=0
textos=""
dispositivos=""
directorios=""
ejecutables=""

for f in "$dir"/*; do
    [ -e "$f" ] || continue
    nombre=$(basename "$f")

    if [ -d "$f" ]; then
        directorios="$directorios $nombre"
        cd=$((cd+1))
    elif [ -b "$f" ] || [ -c "$f" ]; then
        dispositivos="$dispositivos $nombre"
        cdv=$((cdv+1))
    elif [ -x "$f" ] && [ -f "$f" ]; then
        ejecutables="$ejecutables $nombre"
        ce=$((ce+1))
    elif file "$f" | grep -qi text; then
        textos="$textos $nombre"
        ct=$((ct+1))
    fi
done

echo "La clasificación de ficheros del directorio $dir es:"
echo "Hay $ct ficheros de texto:$textos"
echo "Hay $cdv ficheros de dispositivo:$dispositivos"
echo "Hay $cd directorios:$directorios"
echo "Hay $ce ficheros ejecutables:$ejecutables"

exit 0