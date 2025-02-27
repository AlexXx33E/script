#!/bin/bash

menu_principal() {
    echo "Elija el método de instalación del servicio FTP:"
    echo "1) --comandos: Irás al menú de instalación mediante comandos."
    echo "2) --Docker: Empezarás la instalación mediante Docker."
    echo "3) --Ansible: El servicio FTP se instalará mediante el playbook de Ansible seleccionado." 
    echo "4) Salir: Sale del script".
    read -p "Opción: " opcion

if [ "$opcion" == "1" ]; then
    echo "Redirigiendo hacia el menú de instalación por comandos..."
    menu_comandos
elif [ "$opcion" == "2" ]; then
    echo "Redirigiendo hacia el menú de instalación por Docker..."
    menu_docker
elif [ "$opcion" == "3" ]; then
    echo "Redirigiendo hacia el menú de instalación por Ansible..."
    menu_ansible
elif [ "$opcion" == "4" ]; then
    echo "Saliendo..."
    menu_principal
    exit 0
else 
    echo "Opción no válida. Inténtalo de nuevo."
    menu_principal
fi
}

menu_comandos() {
  echo "Instalación servicio FTP."
  echo "--datos_red: Muestra los datos de red de tu equipo."
  echo "--status: Muestra el estado del servicio en ese momento."
  echo "--menu: Elige la opción"
  echo "--help: Muestra la ayuda del programa."
}

menu_docker() {
  echo "Instalación servicio FTP (Docker)."
  echo "--datos_red: Muestra los datos de red de tu equipo."
  echo "--status: Muestra el estado del servicio en ese momento."
  echo "--menu_docker: Muestra las opciones del servicio."
  echo "--help_docker: Muestra la ayuda del programa."
}

menu_ansible() {
  echo "Instalación servicio FTP (con Ansible)."
  echo "--datos_red: Muestra los datos de red de tu equipo."
  echo "--status: Muestra el estado del servicio en ese momento."
  echo "--menu_ansible: Muestra las opciones del servicio."
  echo "--help_docker: Muestra la ayuda del programa."
}

comandos_opciones() {
  echo "--instalacion: Instala el servicio FTP."
  echo "--eliminar: Elimina el servicio FTP."
  echo "--ejecutar: Puesta en marcha del servicio."
  echo "--stop: Parada del servicio."
  echo "--logs: Muestra los logs."
}

opciones_docker() {
  echo "--instalacion_docker: Instala el servicio."
  echo "--eliminar_docker: Elimina el servicio."
  echo "--stop_docker: Parada del servicio."
  echo "--logs_docker: Muestra los logs." 
}

opciones_ansible() {
  echo "--instalacion_ansible: Instala el servicio."
  echo "--eliminar_ansible: Elimina el servicio."
  echo "--stop_ansible: Parada del servicio."
  echo "--logs_ansible: Muestra los logs."
}

instalar_servicio_comandos() {
  echo "Instalando el servicio FTP..."
  sudo apt update && sudo apt install -y vsftpd
  echo "Instalación completada"
}

eliminar_servicio_comandos() {
  echo "Eliminando el servicio FTP por completo..."
  sudo apt purge -y vsftpd && sudo apt autoremove -y
  sudo rm -rf /etc/vsftpd /var/log/vsftpd.log /srv/ftp /home/ftp
  echo "Servicio eliminado completamente."
}

ejecutar_servicio_comandos() {
  echo "Iniciando servicio FTP..."
  sudo systemctl start vsftpd
  echo "El servicio ya está activo."
} 

parar_servicio_comandos() {
  echo "Iniciando servicio FTP..."
  sudo systemctl stop vsftpd
  echo "El servicio está detenido."
} 

mostrar_logs_comandos() {
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
  menu_comandos
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
  comandos_opciones
  exit 0
fi

if [ "$1" == "--instalación" ]; then
  instalar_servicio_comandos
  exit 0
fi

if [ "$1" == "--eliminar" ]; then
  eliminar_servicio_comandos
  exit 0
fi

if [ "$1" == "--ejecutar" ]; then
  ejecutar_servicio_comandos
  exit 0
fi

if [ "$1" == "--stop" ]; then
  parar_servicio_comandos
  exit 0
fi

if [ "$1" == "--logs" ]; then
  mostrar_logs_comandos
  exit 0
fi

if [ "$1" == "--menu_docker" ]; then
  opciones_docker
  exit 0
fi

if [ "$1" == "--help_docker" ]; then
  menu_docker
  exit 0
fi

if [ "$1" == "--menu_ansible" ]; then
  opciones_ansible
  exit 0
fi

if [ "$1" == "--help_ansible" ]; then
  menu_ansible
  exit 0
fi

echo "Opción no válida. Usa --help para mostrar la ayuda del menú."
menu_principal
