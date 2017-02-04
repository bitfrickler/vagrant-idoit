#!/usr/bin/env bash

# Timezone for the system
TimeZone="Europe/Berlin"

######################
##  Install System  ##
######################

# set timezone
rm /etc/timezone
echo $TimeZone > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
    apache2 libapache2-mod-php5 php5 php5-cli php5-xcache php5-common php5-curl php5-gd php5-json php5-ldap php5-mcrypt php5-mysqlnd php5-pgsql mysql-server-5.6 mysql-client-5.6 php5-memcache memcached unzip

#PHP
cat >> /etc/php5/mods-available/i-doit.ini <<EOL
allow_url_fopen = Yes
file_uploads = On
magic_quotes_gpc = Off
max_execution_time = 300
max_file_uploads = 42
max_input_time = 60
max_input_vars = 10000
memory_limit = 128M
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
;; Wert (in Sekunden) sollte größer gleich dem Session Timeout in den Systemeinstellungen von i-doit sein:
session.gc_maxlifetime = 604800
session.cookie_lifetime = 0
EOL

cat >> /etc/php5/mods-available/xcache.ini <<EOL
xcache.shm_scheme = "mmap"
xcache.size  = 16M
xcache.count = 1 # Anzahl CPU-Kerne
xcache.slots = 4K # Abhängig vom Arbeitsspeicher
xcache.var_size  = 32M
xcache.test = Off
xcache.optimizer = On
xcache.cacher = On
xcache.stat = On
EOL

php5enmod i-doit
php5enmod memcache
php5enmod xcache
# Durch einen Fehler im Pakt php5-mcrypt muss dieses Modul manuell aktiviert werden:
php5enmod mcrypt
mkdir -p /etc/php5/conf.d
ln -s /etc/php5/mods-available/i-doit.ini /etc/php5/conf.d/

#apache
cat >> /etc/apache2/sites-available/i-doit.conf <<EOL
<VirtualHost *:80>
        ServerAdmin i-doit@example.net
 
        DocumentRoot /var/www/html/
        <Directory /var/www/html/>
                # Siehe .htaccess im Installationsverzeichnis von i-doit:
                AllowOverride All
                Require all granted
        </Directory>
 
        LogLevel warn
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

a2dissite 000-default
a2ensite i-doit
a2enmod rewrite
service apache2 restart

#mysql
cat >> /etc/mysql/conf.d/i-doit.cnf <<EOL
[mysqld]
  
# This is the number 1 setting to look at for any performance optimization
# It is where the data and indexes are cached: having it as large as possible will
# ensure MySQL uses memory and not disks for most read operations.
#
# Typical values are 1G (1-2GB RAM), 5-6G (8GB RAM), 20-25G (32GB RAM), 100-120G (128GB RAM).
innodb_buffer_pool_size = 256M 
innodb_buffer_pool_instances = 1 # use multiple instances if you have 
                                 # innodb_buffer_pool_size > 10G, 1 every 4GB
 
# Redo log file size, the higher the better.
# MySQL writes two of these log files in a default installation.
innodb_log_file_size = 128M
 
innodb_sort_buffer_size = 64M
sort_buffer_size = 262144 # default
join_buffer_size = 262144 # default
 
max_allowed_packet = 32M
max_heap_table_size = 4M
query_cache_min_res_unit = 4096
query_cache_type = 1
query_cache_limit = 5M
query_cache_size = 20M
 
tmp_table_size = 32M
max_connections = 200
innodb_file_per_table = 1
 
# disable this if you have only one to two CPU cores ( = 0), change it to 4 for a Quad Core.
innodb_thread_concurrency = 0
 
# disable this if you have slow harddisks ( = 0)
innodb_flush_log_at_trx_commit = 1 
innodb_flush_method = O_DIRECT
 
innodb_lru_scan_depth = 2048
table_definition_cache = 1024
table_open_cache = 2048
#table_open_cache_instances = 4 # Only if your have MySQL 5.6 or higher, do not use with MariaDB!
 
sql-mode = ""
EOL

mysql -u root -e"SET GLOBAL innodb_fast_shutdown = 0"
service mysql stop
mv /var/lib/mysql/ib_logfile[01] /tmp
service mysql start