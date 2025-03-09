#!/bin/bash

mostrar_datos_red() {
    echo "-----------------------------"
    echo "DATOS DE RED:"
    ip add show | grep "inet " | cut -d" " -f5,6
    echo "-----------------------------"
}

mostrar_estado_servicio() {
    echo "-----------------------------"
    echo "ESTADO DEL SERVICIO FTP"

    if sudo docker ps -a | grep ftp_server &>/dev/null; then
        echo "El servicio FTP está instalado con Docker"
        if sudo docker ps | grep ftp_server &>/dev/null; then
            echo "El contenedor FTP está en ejecución"
        else
            echo "El contenedor FTP está detenido"
        fi
    elif [ -f /etc/vsftpd_installed_with_ansible ]; then
        echo "El servicio FTP está instalado con Ansible"
        if systemctl is-active vsftpd &>/dev/null; then
            echo "El servicio FTP está activo"
        else
            echo "El servicio FTP está inactivo"
        fi
    elif [ -f /etc/vsftpd_installed_with_commands ]; then
        echo "El servicio FTP está instalado con comandos"
        if systemctl is-active vsftpd &>/dev/null; then
            echo "El servicio FTP está activo"
        else
            echo "El servicio FTP está inactivo"
        fi
    else
        echo "El servicio FTP no está instalado"
    fi
    echo "-----------------------------"
}

menu_principal() {
    echo "----------------------------------------------------"
    echo "MENÚ DE GESTIÓN DEL SERVICIO"
    echo "1) Instalación del servicio"
    echo "2) Elimina el servicio"
    echo "3) Pone en marcha el servicio"
    echo "4) Para el servicio"
    echo "5) Consulta los logs"
    echo "6) Crear usuario"
    echo "7) Eliminar usuario"
    echo "8) Salir"
    echo "----------------------------------------------------"
    read -p "Selecciona una opción (del 1 al 8): " opcion

    case $opcion in
        1) menu_instalacion ;;
        2) eliminar_servicio_comandos ;;
        3) inicia_servicio_comandos ;;
        4) parar_servicio_comandos ;;
        5) menu_logs ;;
        6) crear_usuario ;;
        7) eliminar_usuario ;;
        8) echo "Saliendo del MENÚ PRINCIPAL"; exit 0 ;;
        *) echo "Opción no válida. Inténtalo de nuevo"; menu_principal ;;
    esac
}

crear_usuario() {
    read -p "Introduce el nombre de tu nuevo usuario: " usuario
    sudo useradd -m -d /home/$usuario -s /usr/sbin/nologin $usuario
    sudo passwd $usuario
    echo "El usuario $usuario se creó correctamente."
}

eliminar_usuario() {
    read -p "Introduce el nombre del usuario que quieres eliminar: " usuario
    sudo userdel -r $usuario
    echo "El usuario $usuario se eliminó correctamente"
}

menu_instalacion() {
    echo "----------------------------------------------------"
    echo "MENÚ método de instalación del servicio FTP:"
    echo "1) Instalar mediante COMANDOS"
    echo "2) Instalar mediante DOCKER"
    echo "3) Instalar mediante ANSIBLE"
    echo "4) Volver al menú principal"
    echo "----------------------------------------------------"
    read -p "Seleccione una opción (del 1 al 4): " opcion

    case $opcion in
        1) instalar_con_comandos ;;
        2) instalar_con_docker ;;
        3) instalar_con_ansible ;;
        4) menu_principal ;;
        *) echo "Opción no válida. Inténtalo de nuevo."; menu_instalacion ;;
    esac
}

menu_logs() {
    echo "----------------------------------------------------"
    echo "1) Consulta los logs por FECHA"
    echo "2) Consulta los logs por TIPO (INFO, WARNING, ERROR)"
    echo "3) Mostrar los últimos 20 logs"
    echo "4) Volver al menú principal"
    echo "----------------------------------------------------"
    read -p "Seleccione una opción (del 1 al 4): " opcion

    case $opcion in
        1) consultar_logs_por_fecha ;;
        2) consultar_logs_por_tipo ;;
        3) mostrar_ultimos_logs ;;
        4) menu_principal ;;
        *) echo "Opción no válida. Inténtalo de nuevo"; menu_logs ;;
    esac
}

instalar_con_comandos() {
    echo "Instalando el servicio FTP con COMANDOS..."
    sudo apt update && sudo apt install -y vsftpd
    sudo touch /etc/vsftpd_installed_with_commands
    echo "INSTALACIÓN por comandos completada"
    menu_principal
}

instalar_ansible() {
    echo "Instalando Ansible..."
    sudo apt update
    sudo apt install -y ansible
    if command -v ansible &>/dev/null; then
        echo "Ansible instalado correctamente"
    else
        echo "ERROR: Ansible no se instaló correctamente"
        exit 1
    fi
}

instalar_con_ansible() {
    if ! command -v ansible &>/dev/null; then
        echo "Ansible no está instalado. Instalando Ansible..."
        instalar_ansible
    fi

    echo "Creando playbook de Ansible..."
    cat <<EOF > playbook_ansible_completo.yaml
---
- name: Instalar y configurar servidor FTP en Ubuntu
  hosts: localhost
  become: yes
  tasks:
    - name: Actualizar la cache de apt
      apt:
        update_cache: yes

    - name: Instalar el servicio vsftpd
      apt:
        name: vsftpd
        state: present

    - name: Iniciar y habilitar el servicio vsftpd
      service:
        name: vsftpd
        enabled: yes
        state: started

    - name: Crear usuario ftpuser
      user:
        name: ftpuser
        password: "{{ 'Admin_123' | password_hash('sha512') }}"
        shell: /bin/bash

    - name: Crear directorio para el usuario ftpuser
      file:
        path: /home/ftpuser/ftp
        state: directory
        owner: ftpuser
        group: ftpuser
        mode: '0755'
EOF

    echo "Ejecutando playbook de Ansible..."
    ansible-playbook -i localhost, -c local playbook_ansible_completo.yaml

    if [ $? -eq 0 ]; then
        sudo touch /etc/vsftpd_installed_with_ansible
        echo "Servicio FTP instalado y configurado correctamente con Ansible"
    else
        echo "Error: No se pudo instalar el servicio FTP con Ansible. Revisa los logs."
    fi
    menu_principal
}

instalar_docker() {
    echo "Instalando el servicio FTP con DOCKER..."
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER

    if command -v docker &>/dev/null; then
        echo "Docker instalado correctamente"
        echo "IMPORTANTE: REINICIA la sesión o el equipo para que se apliquen los cambios"
        exit 0
    else
        echo "ERROR: Docker no se instaló correctamente"
    fi
}

instalar_con_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Docker no está instalado. Instalando Docker..."
        instalar_docker
    fi

    echo "Descargando la imagen FTP..."
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
    elif [ -f /etc/vsftpd_installed_with_ansible ]; then
        echo "El servicio FTP fue instalado con Ansible. Eliminándolo..."
        echo "Creando playbook de Ansible..."
        cat <<EOF > playbook_eliminar_ftp.yaml
---
- name: Eliminar servicio FTP en Ubuntu
  hosts: localhost
  become: yes
  tasks:
    - name: Detener el servicio vsftpd si está ejecutado
      service:
        name: vsftpd
        state: stopped
        enabled: no

    - name: Eliminar el servicio vsftpd
      apt:
        name: vsftpd
        state: absent

    - name: Eliminar el usuario ftpuser
      user:
        name: ftpuser
        state: absent
        remove: yes

    - name: Eliminar los directorios asociados al servicio FTP
      file:
        path: "{{ item }}"
        state: absent
      with_items:
        - /etc/vsftpd
        - /var/log/vsftpd.log
        - /srv/ftp
        - /home/ftp
EOF
        ansible-playbook -i localhost, -c local playbook_eliminar_ftp.yaml
        sudo rm /etc/vsftpd_installed_with_ansible
        echo "Servicio FTP eliminado correctamente con Ansible"
    elif [ -f /etc/vsftpd_installed_with_commands ]; then
        echo "El servicio FTP fue instalado con comandos. Eliminándolo..."
        sudo systemctl stop vsftpd
        sudo apt remove --purge vsftpd
        sudo rm -rf /etc/vsftpd
        sudo rm -rf /var/log/vsftpd.log
        sudo rm -rf /srv/ftp
        sudo rm -rf /home/ftp
        sudo rm /etc/vsftpd_installed_with_commands
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
    elif [ -f /etc/vsftpd_installed_with_ansible ]; then
        echo "El servicio FTP fue instalado con Ansible. Iniciando el servicio..."
        if ! systemctl is-active vsftpd &>/dev/null; then
            sudo systemctl start vsftpd
            echo "Servicio vsftpd iniciado correctamente."
        else
            echo "El servicio vsftpd ya está en ejecución."
        fi
    elif [ -f /etc/vsftpd_installed_with_commands ]; then
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
    if sudo docker ps | grep ftp_server &>/dev/null; then
        echo "El servicio FTP fue instalado con Docker. Deteniendo el contenedor..."
        sudo docker stop ftp_server
        echo "El servicio FTP fue detenido correctamente"
    elif [ -f /etc/vsftpd_installed_with_ansible ]; then
        echo "El servicio FTP fue instalado con Ansible. Deteniendo el servicio..."
        if systemctl is-active vsftpd &>/dev/null; then
            sudo systemctl stop vsftpd
            echo "Servicio vsftpd detenido correctamente."
        else
            echo "El servicio vsftpd ya estaba detenido."
        fi
    elif [ -f /etc/vsftpd_installed_with_commands ]; then
        echo "El servicio FTP fue instalado con comandos. Deteniendo el servicio..."
        sudo systemctl stop vsftpd
        echo "Servicio detenido correctamente"
    else
        echo "No se encontró una instalación del servicio FTP"
    fi
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
    echo "Mostrando los últimos 20 logs..."
    sudo journalctl -u vsftpd --no-pager | tail -n 20
    menu_logs
}

mostrar_datos_red
mostrar_estado_servicio
menu_principal
