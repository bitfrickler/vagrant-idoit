#!/usr/bin/env bash

MYSQL_PASSWORD=Admin123#

mysqladmin -u root password Admin123#

mkdir -p /var/www/html/idoit

cd /vagrant/idoit
unzip idoit-1.8.2.zip -d /var/www/html/idoit
unzip idoit-api-1.8.zip -d /var/www/html/idoit

cd /var/www/html/idoit/setup
./install.sh -m idoit_data -s idoit_system -n "Frickel GmbH" -a "Admin123#" -p "Admin123#" -q

cd /vagrant/idoit
mysql -u root --password=$MYSQL_PASSWORD idoit_system < idoit_system.sql
mysql -u root --password=$MYSQL_PASSWORD idoit_data < idoit_data.sql
mysql -u root --password=Admin123# mysql < fix.sql

cp isys_module_licence.class.php /var/www/html/idoit/src/classes/modules/licence/

chown www-data:www-data -R /var/www/html/idoit


# TODO: Set bind address to all interfaces in my.cnf
#bind-address = 127.0.0.1

# after installation of JSON module
#mkdir -p idoit/upload/files
#mkdir -p idoit/upload/images
#chmod 777 idoit/upload/files
#chmod 777 idoit/upload/images/