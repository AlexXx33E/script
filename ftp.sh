#!/bin/bash

set -e

menu_principal() {
    echo "Elija el método de instalación del servicio FTP:"
    echo "1) --comandos: Irás al menú de instalación mediante comandos."
    echo "2) --Docker: Empezarás la instalación mediante Docker."
    echo "3) --Ansible: El servicio FTP se instalará mediante el playbook de Ansible seleccionado." 
    echo "4) Salir: Sale del script."
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
        exit 0
    else 
        echo "Opción no válida. Inténtalo de nuevo."
        menu_principal
    fi
}

menu_comandos() {
    echo "Instalación servicio FTP."
    echo "--menu: Elige la opción"
    echo "--help: Muestra la ayuda del programa."
}

menu_docker() {
    echo "Instalación servicio FTP (Docker)."
    echo "--menu_docker: Muestra las opciones del servicio."
    echo "--help_docker: Muestra la ayuda del programa."
}

menu_ansible() {
    echo "Instalación servicio FTP (con Ansible)."
    echo "--menu_ansible: Muestra las opciones del servicio."
    echo "--help_ansible: Muestra la ayuda del programa."
}

comandos_opciones() {
    echo "--instalacion: Instala el servicio FTP."
    echo "--eliminar: Elimina el servicio FTP."
    echo "--ejecutar: Puesta en marcha del servicio."
    echo "--stop: Parada del servicio."
    echo "--logs: Muestra los logs."
    echo "--crear_usuario: Permite crear un usuario y su carpeta asociada."
    echo "--eliminar_usuario: Permite eliminar un usuario creado y la carpeta asociada a este."
}

instalar_servicio_comandos() {
    echo "Instalando el servicio FTP..."
    sudo apt update && sudo apt install -y vsftpd
    echo "Instalación completada."
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
    echo "Deteniendo servicio FTP..."
    sudo systemctl stop vsftpd
    echo "El servicio está detenido."
} 

crear_usuario() {
    read -r -p "Introduce el nombre de tu nuevo usuario: " usuario
    sudo useradd -m -d /home/$usuario -s /usr/sbin/nologin $usuario
    sudo passwd $usuario
    echo "Usuario $usuario creado correctamente. Su carpeta estará en /home/$usuario."
}

eliminar_usuario() {
    read -r -p "Introduce el nombre de usuario que quieres eliminar: " usuario
    sudo userdel -r $usuario
    echo "Usuario $usuario eliminado junto con su carpeta."
}

ip add
systemctl status vsftpd || echo "Error. El servicio FTP no está instalado."

if [ "$1" == "--help" ]; then
    menu_comandos
    exit 0
fi

if [ "$1" == "--menu" ]; then
    comandos_opciones
    exit 0
fi

if [ "$1" == "--instalacion" ]; then
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

if [ "$1" == "--crear_usuario" ]; then
    crear_usuario
    exit 0
fi

if [ "$1" == "--eliminar_usuario" ]; then
    eliminar_usuario
    exit 0
fi

echo "Opción no válida. Usa --help para mostrar la ayuda del menú."
menu_principal
