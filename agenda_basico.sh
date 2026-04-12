#!/bin/bash

archivo="agenda.txt"

anadir_registro() {
    ./addagenda_basico.sh
}

eliminar_registro() {
    read -p "Nombre a eliminar: " nombre
    grep -v "^$nombre[[:space:]]" "$archivo" > tmp && mv tmp "$archivo"
}

buscar_registro() {
    read -p "Texto a buscar: " texto
    grep -i "$texto" "$archivo"
}

listar_agenda() {
    cat "$archivo"
}

ordenar_agenda() {
    sort "$archivo" -o "$archivo"
}

borrar_agenda() {
    > "$archivo"
}

modificar_registro() {
    read -p "Dato a buscar: " buscar
    read -p "Dato de reemplazo: " reemplazo
    sed -i "s/$buscar/$reemplazo/g" "$archivo"
}

while true
do
    echo "a) Añadir"
    echo "b) Eliminar"
    echo "c) Buscar"
    echo "d) Listar"
    echo "e) Ordenar"
    echo "f) Borrar"
    echo "g) Modificar"
    echo "h) Salir"
    read -p "Opcion: " op

    case $op in
        a) anadir_registro ;;
        b) eliminar_registro ;;
        c) buscar_registro ;;
        d) listar_agenda ;;
        e) ordenar_agenda ;;
        f) borrar_agenda ;;
        g) modificar_registro ;;
        h) exit 0 ;;
        *) echo "Opcion incorrecta" ;;
    esac
done