#!/bin/bash
mostrar_ayuda() {
  echo "Instalación servicio FTP."
  echo "--datos_red: Muestra los datos de red de tu equipo."
  echo "--status: Muestra el estado del servicio."
  echo "--menu: Elige la opción"
  echo "--help: Muestra la ayuda del programa."
}

menu() {
  echo "--instalación: Instala el servicio FTP."
  echo "--eliminar: Elimina el servicio FTP."
  echo "--ejecutar: Puesta en marcha del servicio."
  echo "--stop: Parada del servicio."
  echo "--logs: Muestra los logs."
}

instalar_servicio() {
  echo "Instalando el servicio FTP..."
  sudo apt update && sudo apt install -y vsftpd
  echo "Instalación completada"
}

eliminar_servicio() {
  echo "Eliminando el servicio FTP..."
  sudo apt remove -y vsftpd
  echo "Servicio eliminado."
}

ejecutar_servicio() {
  echo "Iniciando servicio FTP..."
  sudo systemctl start vsftpd
  echo "El servicio ya está activo."
} 

parar_servicio() {
  echo "Iniciando servicio FTP..."
  sudo systemctl stop vsftpd
  echo "El servicio está detenido."
} 



if [ "$1" == "--help" ]; then
  mostrar_ayuda
  exit 0
fi

if [ "$1" == "--datos_red" ]; then
  ip add
  exit 0
fi

if [ "$1" == "--status" ]; then
  systemctl status vsftpd 
  #Control de errores ("Error. No está instalado.")
  exit 0
fi

if [ "$1" == "--menu" ]; then
  menu
  exit 0
  if [ -z "$2" == "--instalación" ]
fi

 