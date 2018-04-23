#!/usr/bin/env bash

DEFAULT_PASSWORD="$1"

mysql -u root -e"UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE User = 'root'; FLUSH PRIVILEGES;"
mysql -u root -e"UPDATE mysql.user SET Password=PASSWORD('${DEFAULT_PASSWORD}') WHERE User='root'; FLUSH PRIVILEGES;"

mkdir -p /var/www/html/idoit

cd /vagrant/idoit
unzip idoit.zip -d /var/www/html/i-doit > /dev/null
unzip idoit-api.zip -d /var/www/html/i-doit > /dev/null

cd /var/www/html/i-doit/setup
./install.sh -m idoit_data -s idoit_system -n "Frickel GmbH" -a "${DEFAULT_PASSWORD}" -p "${DEFAULT_PASSWORD}" -q

cd /vagrant/idoit
mysql -u root --password=${DEFAULT_PASSWORD} idoit_system < idoit_system.sql
mysql -u root --password=${DEFAULT_PASSWORD} idoit_data < idoit_data.sql
mysql -u root --password=${DEFAULT_PASSWORD} mysql < fix.sql

cp isys_module_licence.class.php /var/www/html/i-doit/src/classes/modules/licence/

cd /var/www/html/i-doit
chown www-data:www-data -R .
find . -type d -name \* -exec chmod 775 {} \;
find . -type f -exec chmod 664 {} \;
chmod 774 controller tenants import updatecheck *.sh setup/*.sh

# bind mysql to all interfaces (comment out if you don't care for remote connections)

echo "[mysqld]" >> /etc/mysql/my.cnf
echo "bind-address=0.0.0.0" >> /etc/mysql/my.cnf

systemctl restart mysql.service

# after installation of JSON module
#mkdir -p idoit/upload/files
#mkdir -p idoit/upload/images
#chmod 777 idoit/upload/files
#chmod 777 idoit/upload/images/