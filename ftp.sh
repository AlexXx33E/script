#!/bin/bash

mostrar_datos_red() {
    echo "-----------------------------"
    echo "DATOS DE RED:"
    ip add show | grep "inet " | cut -d" " -f5,6
    echo "-----------------------------"
}

mostrar_estado_servicio() {
    echo "-----------------------------"
    echo "ESTADO DEL SERVICO FTP"
    if systemctl is-active vsftpd &>/dev/null; then 
        echo "El servicio FTP está activo"
    else
        echo "El servicio FTP está inactivo"
    fi
    echo "-----------------------------"

}
menu_principal() {
    echo "----------------------------------------------------"
    echo "MENÚ DE GESTIÓN DEL SERVICIO"
    echo "1) Instalación del servicio"
    echo "2) Elimina el servicio"
    echo "3) Pone en marcha el servicio"
    echo "4) Para el servicio "
    echo "5) Consulta los logs"
    echo "6) Salir"
    read -p "Seleciona una opción (del 1 al 6): " opcion

    if [ "$opcion" == "1" ]; then
        menu_instalacion
    elif [ "$opcion" == "2" ]; then
        eliminar_servicio_comandos
    elif [ "$opcion" == "3" ]; then
       ejecutar_servicio_comandos
    elif [ "$opcion" == "4" ]; then
        parar_servicio_comandos
    elif [ "$opcion" == "5" ]; then
        menu_logs
    elif [ "$opcion" == "6" ]; then
        echo "Saliendo del MENÚ PRINCIPAL"
        exit 0
    else
        echo "Opción no válida. Intentalo de nuevo"
        menu_principal
    fi
}


menu_instalacion() {
    echo "----------------------------------------------------"
    echo "MENÚ método de instalación del servicio FTP:"
    echo "1) Instalar mediante COMANDOS"
    echo "2) Instalar mediande ANSIBLE"
    echo "3) Instalar mediante DOCKER" 
    echo "4) Volver al menú principal"
    read -p "Seleccione una opción (del 1 al 4): " opcion

    if [ "$opcion" == "1" ]; then
        echo "Instalando por comandos..."
        instalar_con_comandos
    elif [ "$opcion" == "2" ]; then
        echo "Instalación por Docker..."
        instalar_con_ansible
    elif [ "$opcion" == "3" ]; then
        echo "Instalando por Ansible..."
        instalar_con_docker
    elif [ "$opcion" == "4" ]; then
        echo "Volviendo...."
        menu_principal
    else 
        echo "Opción no válida. Inténtalo de nuevo."
        menu_instalacion
    fi
}




menu_comandos() {
    echo "Instalación servicio FTP."
    echo "--menu: Elige la opción"
    echo "--help: Muestra la ayuda del programa."
}

menu_docker() {
    echo "Instalación servicio FTP (Docker)."
    echo "--instalacion_docker: Instala el servicio."
    echo "--eliminar_docker: Elimina el servicio."
    echo "--stop_docker: Parada del servicio."
    echo "--logs_docker: Muestra los logs."
}

instalar_servicio_docker() {
    echo "Creando Dockerfile y construyendo imagen para vsftpd..."
    cat <<EOF > Dockerfile
FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean
COPY vsftpd.conf /etc/vsftpd.conf
RUN useradd -m -d /home/usuario_ftp -s /usr/sbin/nologin usuario_ftp && \
    echo "usuario_ftp:pass_ftp" | chpasswd
RUN mkdir -p /home/usuario_ftp/ftp_files && \
    chown usuario_ftp:usuario_ftp /home/usuario_ftp/ftp_files && \
    chmod 755 /home/usuario_ftp
EXPOSE 21 
CMD ["vsftpd", "-o", "listen=NO", "-o", "listen_ipv6=YES"]
EOF
    docker build -t vsftpd_server .
    echo "Imagen Docker creada con éxito. Para ejecutarla usa: docker run -d -p 21:21 vsftpd_server"
}

eliminar_servicio_docker() {
  echo "Eliminando contenedor vsftpd..."
  docker rm -f vsftpd_server || echo "No hay contenedor en ejecución."
  docker rmi -f vsftpd_server || echo "No hay imagen de Docker creada."
  echo "Servicio Docker eliminado correctamente."
}

detener_servicio_docker() {
    echo "Deteniendo contenedor vsftpd..."
    docker stop vsftpd_server || echo "El contenedor ya está detenido."
}

mostrar_logs_docker() {
    echo "Mostrando logs del contenedor FTP..."
    docker logs vsftpd_server
}

menu_ansible() {
    echo "Instalación servicio FTP (con Ansible)."
    echo "--menu_ansible: Muestra las opciones del servicio."
    echo "--help_ansible: Muestra la ayuda del programa."
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
if [ "$1" == "--menu_principal" ]; then
  menu_principal
  exit 0
fi

if [ "$1" == "--comandos" ]; then
    menu_comandos
    exit 0
fi

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


if [ "$1" == "--Docker" ]; then
    menu_docker
    exit 0
fi

if [ "$1" == "--instalacion_docker" ]; then
    instalar_servicio_docker
    exit 0
fi

if [ "$1" == "--eliminar_docker" ]; then
    eliminar_servicio_docker
    exit 0
fi

if [ "$1" == "--stop_docker" ]; then
    detener_servicio_docker
    exit 0
fi

if [ "$1" == "--logs_docker" ]; then
    mostrar_logs_docker
    exit 0
fi

else
  echo "Opción no válida. Usa --help para mostrar la ayuda del menú."
  menu_principal

