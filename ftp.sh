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

    if sudo docker ps -a | grep ftp_server &>/dev/null; then
        echo "El servicio FTP está instalado con Docker"
        if sudo docker ps | grep ftp_server &>/dev/null; then
            echo "El contenedor FTP está en ejecución"
        else
            echo "El contenedor FTP está en ejecución"
        fi
    else
        if systemctl is-active vsftpd &>/dev/null; then 
            echo "El servicio FTP está activo"
        else
            echo "El servicio FTP está inactivo"
        fi
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
    echo "6) Crear usuario"
    echo "7) Eliminar usuario"
    echo "8) Salir"
    read -p "Seleciona una opción (del 1 al 8): " opcion

    if [ "$opcion" == "1" ]; then
        menu_instalacion
    elif [ "$opcion" == "2" ]; then
        eliminar_servicio_comandos
    elif [ "$opcion" == "3" ]; then
       inicia_servicio_comandos
    elif [ "$opcion" == "4" ]; then
        parar_servicio_comandos
    elif [ "$opcion" == "5" ]; then
        menu_logs
    elif [ "$opcion" == "6" ]; then
        crear_usuario
    elif [ "$opcion" == "7" ]; then
        eliminar_usuario
    elif [ "$opcion" == "8" ]; then
        echo "Saliendo del MENÚ PRINCIPAL"
        exit 0
    else
        echo "Opción no válida. Intentalo de nuevo"
        menu_principal
    fi
}

crear_usuario() {
    read -p "Introduce el nombre de tu nuevo usuario: " usuario
    sudo useradd -m -d /home/$usuario -s /usr/sbin/nologin $usuario
    sudo passwd $usuario
    echo "El usuario $usuario se creo correctamente."
}

eliminar_usuario() {
    read -p "Introduc el nombre del usuario que quieres eliminar: " usuario
    sudo userdel -r $usuario
    echo "El ususario $usuario se elimino correctamente"
}

menu_instalacion() {
    echo "----------------------------------------------------"
    echo "MENÚ método de instalación del servicio FTP:"
    echo "1) Instalar mediante COMANDOS"
    echo "2) Instalar mediande ANSIBLE"
    echo "3) Instalar mediante DOCKER" 
    echo "4) Volver al menú principal"
     echo "----------------------------------------------------"
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

menu_logs() {
    echo "----------------------------------------------------"
    echo "1) Consulta los logs por FECHA"
    echo "2) Consula los logs por TIPO (INFO, WARNING, ERROR)"
    echo "3) Mostrar los últimos 20 logs"
    echo "4) Volver al menú principal"
    echo "----------------------------------------------------"
    read -p "Seleccione una opción (del 1 al 4): " opcion

    if [ "$opcion" == "1" ]; then
        consultar_logs_por_fecha
    elif [ "$opcion" == "2" ]; then
        consultar_logs_por_tipo
    elif [ "$opcion" == "3" ]; then
        mostrar_ultimos_logs
    elif [ "$opcion" == "4" ]; then
        menu_principal
    else
        echo "Opción no válida. Intentalo de nuevo"
        menu_logs
    fi
}

instalar_con_comandos() {
    echo "Instalando el servicio FTP con COMANDOS..."
    sudo apt update && sudo apt install -y vsftpd
    echo "INSTALACIÓN por comandos completada"
    menu_principal
}

instalar_con_ansible() {
    echo "Instalando el servicio FTP con ANSIBLE..."
    # AQUI VA EL ANSIBLE (instalación)
    echo "INSTALACIÓN por ansible completada"
    menu_principal
}

instalar_docker() {
    echo "Instalando el servicio FTP con DOCKER..."
    sudo apt update 
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-li containerd.io
    sudo usermod -aG docker $USER

    if command -v docker &> dev/null; then
        echo "Docker instalado correctamente"
        echo "IMPORTANTE: REINICIA la sesión o el equipo para que se aplique los cambios"
    exit 0
    else 
        echo "ERROR: El docke no se instaló correctamente"
    fi
}

instalar_con_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Docker no está instalado. Instalando Docker..."
        instalar_docker
    fi

    echo "Descargando la imagen FTP...."
    sudo docker pull fauria/vsftpd

    echo "Ejecutando el contenedor FTP..."
    sudo docker run -d \
        --name ftp_server \
        -p 21:21 \
        -p 20:20 \
        -p 21100-21110:21100-21110 \
        -e FTP_USER=ftpuser \
        -e FTP_PASS=ftppassword \
        -e PASV_MIN_PORT=21100 \
        -e PASV_MAX_PORT=21110 \
        --restart always \
        fauria/vsftpd

    if [ $? -eq 0 ]; then
        echo "Servicio FTP (Docker) instalado y en ejecución"
        sudo docker pull fauria/vsftpd
        echo "El servicio FTP se ha iniciado automáticamente."
    else
        echo "Error: No se pudo ejecutar el contenedor FTP. Revisa los logs."
        sudo docker logs ftp_server
    fi

    menu_principal
}

eliminar_servicio_comandos() {
    echo "Eliminando el servicio FTP..."

    if sudo docker ps -a | grep ftp_server &>/dev/null; then
        echo "El servicio FTP fue instalado con Docker. Eliminando el contenedor..."
        sudo docker stop ftp_server
        sudo docker rm ftp_server
        sudo docker rmi fauria/vsftpd
        echo "Servicio FTP eliminado correctamente de Docker"
    elif systemctl list-units --full -all | grep -q vsftpd; then
        echo "El servicio FTP fue instalado con comandos. Eliminandolo..."
        sudo systemctl stop vsftpd
        sudo apt remove --purge vsftpd
        sudo rm -rf /etc/vsftpd
        sudo rm -rf /var/log/vsftpd.log
        sudo rm -rf /srv/ftp
        sudo rm -rf /home/ftp
        sudo reboot
        echo "Servicio eliminado completamente"
    else 
        echo "No se encontró una instalación del servicio FTP"
    fi

    menu_principal
}

inicia_servicio_comandos() {
    echo "Iniciando el servicio FTP..."
    if sudo docker ps -a | grep ftp_server &>/dev/null; then
        echo "El servicio FTP fue instalado con Docker. Iniciando contenedor..."
        sudo docker start ftp_server
        echo "El servicio FTP se inició correctamente"
    elif systemctl list-units --full -all | grep -q vsftpd; then
        echo "El servicio FTP fue instalado con comandos. Iniciando..."
        sudo systemctl start vsftpd
        echo "Servicio FTP iniciado"
    else 
        echo "No se encontró una instalación del servicio FTP"
    fi
    menu_principal
}

parar_servicio_comandos() {
    echo "Deteniendo el servicio FTP..."
    
    sudo systemctl stop vsftpd
    echo "Servicio detenido"
    menu_principal
}

consultar_logs_por_fecha() {
    read -p "Ingrese la fecha (YYYY-MM-DD): " fecha
    sudo journalctl -u vsftpd --since "$fecha"
    menu_logs
}

consultar_logs_por_tipo() {
    read -p "Ingrese el tipo de log (INFO, WARNING, ERROR): " tipo
    sudo journalctl -u vsftpd --no-pager | grep -i "$tipo"
    menu_logs
}

mostrar_ultimos_logs() {
    echo "Mostrando los últimos 20 logs...."
    sudo journalctl -u vsftpd --no-pager | tail -n 20
    menu_logs
}

mostrar_datos_red
mostrar_estado_servicio
menu_principal