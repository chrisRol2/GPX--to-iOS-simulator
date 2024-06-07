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



booted_devices=()

# Obtener la lista de dispositivos y leer línea por línea
while IFS= read -r line; do
    # Si la línea contiene "(Booted)", agregarla al array
    if [[ $line == *"(Booted)"* ]]; then
        booted_devices+=("$line")
    fi
done < <(xcrun simctl list devices | grep -E 'iOS|Booted')

# Mostrar el contenido del array de dispositivos booteados
echo "Dispositivos Booteados:"
index=0
for device in "${booted_devices[@]}"; do
    echo "($index) $device"
    ((index++))
done

booted_device_ids=()

# Iterar sobre el array de dispositivos booteados y extraer los IDs
for device in "${booted_devices[@]}"; do
    # Extraer el ID del dispositivo y agregarlo al array
    device_id=$(echo "$device" | awk -F'[()]' '{print $2}')
    booted_device_ids+=("$device_id")
done


read -p "Ingrese el número del dispositivo deseado: " selected_index


selected_device="${booted_devices[selected_index]}"
device_id=$(echo "$selected_device" | awk -F'[()]' '{print $2}')


xcrun simctl location "$device_id" start  --distance=1 --speed="$SPEED" --interval=1 -- $COORDINATES