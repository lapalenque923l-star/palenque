#!/bin/bash
# Script grabación vídeo explicativo

ffmpeg -f x11grab -s 1920x1080 -i :0.0 -f alsa -i default \
  -c:v libx264 -preset slow -crf 18 -c:a aac \
  "demo-despliegue-joomla.mp4" &
PID=$!

# Mostrar interfaz
./despliegue-joomla-gui.sh

kill $PID
