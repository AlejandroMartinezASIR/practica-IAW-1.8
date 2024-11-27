#!/bin/bash

# Estas variables se utilizarán a lo largo del script para evitar valores fijos (hardcoding).
source .env

# Descarga la última versión estable de Moodle desde la URL oficial. El archivo se guarda localmente con el nombre `moodle.zip`.
wget https://download.moodle.org/stable401/moodle-latest-401.zip -O moodle.zip

# Descomprime el archivo descargado `moodle.zip`.
unzip moodle.zip

# Mueve la carpeta descomprimida de Moodle al directorio raíz del servidor web Apache.
mv moodle /var/www/html/

# Cambia el propietario y grupo de los archivos de Moodle a `www-data`, el usuario predeterminado de Apache.
chown -R www-data:www-data /var/www/html/moodle

# Cambia los permisos de los archivos a `755` (lectura y ejecución para todos, escritura solo para el propietario).
sudo chmod -R 755 /var/www/html/moodle

# Creamos la base de datos y el usuario de la base de datos
mysql -e "CREATE DATABASE $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

