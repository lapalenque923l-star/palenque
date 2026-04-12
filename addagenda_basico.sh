#!/bin/bash

archivo="agenda.txt"

anadir() {
    while true
    do
        read -p "Nombre (FIN para acabar): " nombre
        if [ "$nombre" = "FIN" ]; then
            break
        fi

        read -p "Direccion: " direccion
        read -p "Telefono: " telefono

        echo -e "$nombre\t$direccion\t$telefono" >> "$archivo"
    done
}

anadir
