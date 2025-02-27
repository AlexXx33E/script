#!/bin/bash

menu_principal() {
    echo "Elija el método de instalación del servicio FTP:"
    echo "1) --comandos: Irás al menú de instalación mediante comandos."
    echo "2) --Docker: Empezarás la instalación mediante Docker."
    echo "3) --Ansible: El servicio FTP se instalará mediante el playbook de Ansible seleccionado." 
    echo "4) Salir: Sale del script".
    read -p "Opción: " opcion
}

menu_comandos() {
  echo "Instalación servicio FTP."
  echo "--datos_red: Muestra los datos de red de tu equipo."
  echo "--status: Muestra el estado del servicio."
  echo "--menu: Elige la opción"
  echo "--help: Muestra la ayuda del programa."
}

comandos_opciones() {
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
  echo "Eliminando el servicio FTP por completo..."
  sudo apt purge -y vsftpd && sudo apt autoremove -y
  sudo rm -rf /etc/vsftpd /var/log/vsftpd.log /srv/ftp /home/ftp
  echo "Servicio eliminado completamente."
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

mostrar_logs() {
  echo "Selecciona una opción para consultar los logs:"
  echo "1- Mostrar los últimos 20 logs"
  echo "2- Consulta por tipo (INFO, WARNING, ERROR)"
  echo "3- Consulta por fecha"
  echo "4- Salir"
  read -p "Opción: " opcion_logs

  if [ "$opcion_logs" == "1" ]; then
    sudo journalctl -u vsftpd --no-pager | tail -n 20
  elif [ "$opcion_logs" == "2" ]; then
    read -p "Ingrese el tipo de log (INFO, WARNING, ERROR): " tipo
    sudo journalctl -u vsftpd --no-pager | grep -i "$tipo"
  elif [ "$opcion_logs" == "3" ]; then
    read -p "Ingrese la fecha (YYYY-MM-DD): " fecha
    sudo journalctl -u vsftpd --since "$fecha"
  elif [ "$opcion_logs" == "4" ]; then
    echo "Saliendo..."
    return
  eliminar_servicio
    echo "Opción no válida"
  fi
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
  systemctl status vsftpd || echo "Error. No está instalado."
  exit 0
fi

if [ "$1" == "--menu" ]; then
  menu
  exit 0
fi

if [ "$1" == "--instalación" ]; then
  instalar_servicio
  exit 0
fi

if [ "$1" == "--eliminar" ]; then
  eliminar_servicio
  exit 0
fi

if [ "$1" == "--ejecutar" ]; then
  ejecutar_servicio
  exit 0
fi

if [ "$1" == "--stop" ]; then
  parar_servicio
  exit 0
fi

if [ "$1" == "--logs" ]; then
  mostrar_logs
  exit 0
fi

echo "Opción no válida. Usa --help para mostrar la ayuda del menú."
exit 1
