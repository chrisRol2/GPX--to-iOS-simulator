#!/bin/bash

# Verifica si se proporcionaron los argumentos 
if [ $# -ne 2 ]; then
  echo "Uso: $0 archivo.gpx velocidad_km_h"
  exit 1
fi

# Verifica si el archivo GPX existe
if [ ! -f "$1" ]; then
  echo "El archivo $1 no existe."
  exit 1
fi

# Verifica si la velocidad es un número válido
if ! [[ $2 =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo "La velocidad debe ser un número válido."
  exit 1
fi

# Convertir velocidad de km/h a m/s
SPEED=$(echo "scale=2; $2 / 3.6" | bc)

# Extraer las coordenadas del archivo GPX y las convertir al formato requerido para el comando 'start'
echo "Convirtiendo el archivo $1..."
COORDINATES=$(sed -nE 's|<trkpt lat="([^"]*)" lon="([^"]*)">|\1,\2|p' "$1")

# Verificar si se encontraron coordenadas
if [ -z "$COORDINATES" ]; then
  echo "No se encontraron coordenadas en el archivo GPX."
  exit 1
fi

xcrun simctl location booted start --distance=1 --speed="$SPEED" --interval=1 -- $COORDINATES
