# Práctica IAW 1.8: Despliegue de Moodle Automatizado con HTTPS

Este proyecto proporciona un conjunto de scripts y configuraciones para desplegar Moodle en un entorno LAMP (Linux, Apache, MySQL, PHP) utilizando HTTPS con **Let's Encrypt**. Está diseñado para facilitar y automatizar la configuración en entornos de producción o desarrollo.

### estructura del repositorio:
```
├── README.md
├── conf
│   └── 000-default.conf
└── scripts
    ├── .env
    ├── install_lamp.sh
    ├── setup_letsencrypt_https.sh
    └── deploy_moodle.sh
```

## .env
Configuramos las variables de todos los scripts

    LE_DOMAIN=practica-wordpress.ddnsking.com/
    LE_EMAIL=demo@demo.es
    DB_NAME=moodle
    DB_USER=moodleuser
    DB_PASSWORD=moodlepassword

### install_lamp.sh
Muestra todos los comandos que se van ejecutando

    set -ex

Actualizamos los repositorios

    apt update

Actualizamos los paquetes 

    apt upgrade -y

Instalamos el servidor web **Apache**

    apt install apache2 -y

Habilitamos el modulo rewrite

    a2enmod rewrite

Copiamos la configuración predeterminada del servidor

    cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf


Instalamos **PHPMyAdmin**

    sudo apt install php libapache2-mod-php php-mysql -y

Reiniciamos servicio

    systemctl restart apache2

Instalamos  el sistema gestor de datos **MySQL**

    apt install mysql-server -y

Modificamos el propietario

    chown -R www-data:www-data /var/www/html

Después de habilitar el módulo deberá reiniciar el servicio de Apache.

    systemctl restart apache2
    a2ensite 000-default.conf

### setup_letsencrypt_https.sh
Muestra todos los comandos que se van ejecutando

    set  -ex

Ponemos las variables del archivo *.env*

    source  .env


Instalamos y actualizamos **Snap**

    snap  install  core

    snap  refresh  core

  

Eliminamos cualquier instalación previa de **Certbot** con **apt**

    apt  remove  certbot -y

  

Instalamos la aplicación **Certbot**

    snap  install  --classic  certbot
    a2dissite default-ssl.conf
  
Obtenemos el certificado y configuramos el servidor web **Apache**

Ejecutamos el comando **Certbot**

    certbot  --apache  -m  $LE_EMAIL  --agree-tos  --no-eff-email  -d  $LE_DOMAIN  --non-interactive

### Deploy_moodle.sh

Carga las variables de entorno desde el archivo `.env`.

    source .env

Descarga la última versión estable de Moodle y la guarda como `moodle.zip`.
    wget https://download.moodle.org/stable401/moodle-latest-401.zip -O moodle.zip

Descomprime el archivo `moodle.zip` descargado.
    
    unzip moodle.zip

Mueve los archivos de Moodle al directorio raíz de Apache.

    mv moodle /var/www/html/

Cambia el propietario de los archivos de Moodle al usuario y grupo `www-data` (usado por Apache).

    chown -R www-data:www-data /var/www/html/moodle

Establece permisos de lectura y ejecución para todos, y permisos de escritura solo para el propietario.

    chmod -R 755 /var/www/html/moodle

Creamos la base de datos con el susuario.

    mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

    mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"

    mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"

Recarga los privilegios en MySQL para asegurarse de que los cambios están aplicados.

    sudo mysql -e "FLUSH PRIVILEGES;"
