#!/bin/bash
#
# Setup the the box. This runs as root

apt-get -y update

apt-get -y install curl

# You can install anything you need here.

# Install Apache
apt-get -y install apache2

# Install PHP5 + libraries
apt-get -y install php5 libapache2-mod-php5 php5-curl php5-mysql php5-gd php5-mcrypt

# Install imagemagick (for TYPO3)
apt-get -y install imagemagick imagemagick-common

# Install graphicsmagick (for TYPO3)
apt-get -y install graphicsmagick

# Install git & curl
apt-get -y install git curl

# Install tools
apt-get -y install build-essential software-properties-common iotop mytop iftop mc vim wget tmux

# Install MySQL
apt-get -y install debconf-utils > /dev/null 2>&1
debconf-set-selections <<< "mysql-server mysql-server/root_password password 1234"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 1234"
apt-get -y install mysql-server > /dev/null 2>&1

# Install SQlibsqlite3-dev ruby1.9.1-dev
apt-get -y install libsqlite3-dev ruby1.9.1-dev > /dev/null 2>&1

# Install openjdk-7
apt-get -y install openjdk-7-jdk > /dev/null 2>&1

# Install mailcatcher as a Ruby gem
gem install mailcatcher > /dev/null 2>&1

# Adding mailcatcher.conf
cat > /etc/init/mailcatcher.conf <<'EOF'
description "Mailcatcher"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec /usr/bin/env mailcatcher --foreground --http-ip=0.0.0.0
EOF

# Adding mailcatcher as php5 module.conf
echo "sendmail_path = /usr/bin/env catchmail -f test@local.dev" | sudo tee /etc/php5/mods-available/mailcatcher.ini
php5enmod mailcatcher  > /dev/null 2>&1

# Set up vhost
cat > /etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerName localhost
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/shared/site
    SetEnv TYPO3_CONTEXT Development/Vagrant
    <Directory "/var/www/shared/site">
        Options Indexes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# PHP.ini additional settings
cat > /etc/php5/apache2/conf.d/30-vagrant.ini <<'EOF'
memory_limit = 384M
max_execution_time=240
upload_max_filesize=200M
post_max_size=400M
max_input_vars=1500

EnableSendfile Off

date.timezone=Europe/Stockholm

opcache.revalidate_freq=0
; Comment line opcache.validate_timestamps=0  when developing
;opcache.validate_timestamps=0
opcache.max_accelerated_files=7963
opcache.memory_consumption=192
opcache.interned_strings_buffer=16
opcache.fast_shutdown=1
EOF

##Adding all locales
#sudo ln -s /usr/share/i18n/SUPPORTED /var/lib/locales/supported.d/all > /dev/null 2>&1
#sudo locale-gen  > /dev/null 2>&1

#Adding some locales
locale-gen en_AU.utf8 > /dev/null 2>&1
locale-gen en_DK.utf8 > /dev/null 2>&1
locale-gen en_US.utf8 > /dev/null 2>&1
locale-gen da_DK.utf8 > /dev/null 2>&1
locale-gen en_GB.utf8 > /dev/null 2>&1
locale-gen de_DE.utf8 > /dev/null 2>&1
locale-gen ro_RO.utf8 > /dev/null 2>&1
locale-gen fi_FI.utf8 > /dev/null 2>&1
locale-gen nb_NO.utf8 > /dev/null 2>&1
locale-gen nn_NO.utf8 > /dev/null 2>&1
locale-gen is_IS.utf8 > /dev/null 2>&1
locale-gen sv_SE.utf8 > /dev/null 2>&1
locale-gen uk_UA.utf8 > /dev/null 2>&1

# enable mod rewrite
a2enmod rewrite > /dev/null 2>&1

# enable mod expires
a2enmod expires > /dev/null 2>&1

#Adding mysql settings
cat > /etc/mysql/conf.d/vagrant.cnf <<'EOF'
[mysqld]
key_buffer = 64M
sort_buffer = 1M
join_buffer = 12M
max_allowed_packet = 8M
max_heap_table_size = 320M
table_cache = 3096
thread_cache_size = 4
query_cache_limit = 512M
query_cache_size = 128M
tmp_table_size = 320M
#innodb_buffer_pool_size = 256M
innodb_buffer_pool_size = 1024M
innodb_flush_log_at_trx_commit = 0
max_allowed_packet=64M
skip-name-resolve=ON
#skip_networking=ON
bulk_insert_buffer_size=32M
#innodb_flush_method = O_DIRECT
# Allow remote connections to mysql on virtual machine
bind-address = 0.0.0.0

#[mysql]
#sql_log_bin=0
#sql_log_off=1
EOF
#Allow mysql root user remote access
mysql -uroot -p1234 -e "GRANT ALL ON *.* to root@'%' IDENTIFIED BY '1234';"
