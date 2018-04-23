#!/usr/bin/env bash

TimeZone="Europe/Berlin"

rm /etc/timezone
echo $TimeZone > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

apt-get update

apt-get -y remove --purge vim-tiny


#apt-get -y upgrade

DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
    libapache2-mod-php mariadb-client mariadb-server php php-bcmath php-cli php-common php-curl php-gd php-imagick php-json php-ldap php-mcrypt php-memcached php-mysql php-pgsql php-soap php-xml php-zip memcached unzip moreutils

#PHP
cat >> /etc/php/7.0/mods-available/i-doit.ini <<EOL
allow_url_fopen = Yes
file_uploads = On
magic_quotes_gpc = Off
max_execution_time = 300
max_file_uploads = 42
max_input_time = 60
max_input_vars = 10000
memory_limit = 256M
post_max_size = 128M
register_argc_argv = On
register_globals = Off
short_open_tag = On
upload_max_filesize = 128M
display_errors = Off
display_startup_errors = Off
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
log_errors = On
default_charset = "UTF-8"
default_socket_timeout = 60
date.timezone = Europe/Berlin
session.gc_maxlifetime = 604800
session.cookie_lifetime = 0
mysqli.default_socket = /var/run/mysqld/mysqld.sock
EOL

phpenmod i-doit
phpenmod memcache
systemctl restart apache2.service

#apache
a2dissite 000-default

cat >> /etc/apache2/sites-available/i-doit.conf <<EOL
<VirtualHost *:80>
        ServerAdmin i-doit@example.net
 
        DocumentRoot /var/www/html/
        <Directory /var/www/html/>
                AllowOverride All
                Require all granted
        </Directory>
 
        LogLevel warn
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

a2ensite i-doit
a2enmod rewrite
systemctl restart apache2.service

#mysql

mysql -u root -e"SET GLOBAL innodb_fast_shutdown = 0"
systemctl stop mysql.service
mv /var/lib/mysql/ib_logfile[01] /tmp

cat >> /etc/mysql/mariadb.conf.d/99-i-doit.cnf <<EOL
[mysqld]
  
# This is the number 1 setting to look at for any performance optimization
# It is where the data and indexes are cached: having it as large as possible will
# ensure MySQL uses memory and not disks for most read operations.
#
# Typical values are 1G (1-2GB RAM), 5-6G (8GB RAM), 20-25G (32GB RAM), 100-120G (128GB RAM).
innodb_buffer_pool_size = 256M
 
# Use multiple instances if you have innodb_buffer_pool_size > 10G, 1 every 4GB
innodb_buffer_pool_instances = 1
 
# Redo log file size, the higher the better.
# MySQL/MariaDB writes two of these log files in a default installation.
innodb_log_file_size = 128M
 
innodb_sort_buffer_size = 64M
sort_buffer_size = 262144 # default
join_buffer_size = 262144 # default
 
max_allowed_packet = 32M
max_heap_table_size = 4M
query_cache_min_res_unit = 4096
query_cache_type = 1
query_cache_limit = 5M
query_cache_size = 80M
 
tmp_table_size = 32M
max_connections = 200
innodb_file_per_table = 1
 
# Disable this (= 0) if you have only one to two CPU cores, change it to 4 for a quad core.
innodb_thread_concurrency = 0
 
# Disable this (= 0) if you have slow harddisks
innodb_flush_log_at_trx_commit = 1
innodb_flush_method = O_DIRECT
 
innodb_lru_scan_depth = 2048
table_definition_cache = 1024
table_open_cache = 2048
# Only if your have MySQL 5.6 or higher, do not use with MariaDB!
#table_open_cache_instances = 4
 
innodb_stats_on_metadata = 0
 
sql-mode = ""
EOL

systemctl start mysql.service