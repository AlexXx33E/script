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

    if [ "$opcion" == "1"]; then
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

instalar_con_docker() {
    echo "Instalando el servicio FTP con DOCKER..."
    # AQUI VA EL CONTENEDOR DE DOCKER"
    echo "INSTALACIÓN por docker completada"
    menu_principal
}