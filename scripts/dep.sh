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
apt-get -y install build-essential software-properties-common iotop mytop iftop htop mc vim wget tmux

# node
apt-get -y install npm nodejs-legacy

# Install log.io
sudo npm install -g log.io --user "vagrant"

cat > /etc/init/log.io-server.conf <<'EOF'
description "start log.io server"

start on runlevel [2345]
stop on runlevel [016]
respawn

exec su -s /bin/sh -c 'exec "$0" "$@"' vagrant -- /usr/local/bin/log.io-server
EOF

cat > /etc/init/log.io-harvester.conf <<'EOF'
description "start log.io harvester"

start on runlevel [2345]
stop on runlevel [016]
respawn

exec su -s /bin/sh -c 'exec "$0" "$@"' vagrant -- /usr/local/bin/log.io-harvester
EOF

cat > /home/vagrant/.log.io/harvester.conf <<'EOF'
exports.config = {
  nodeName: "t3kit",
  logStreams: {
    apache: [
      "/var/log/apache2/error.log"
    ],
    mysql: [
      "/var/log/mysql/error.log",
      "/var/log/mysql/mysql-slow.log"
    ]
  },
  server: {
    host: '0.0.0.0',
    port: 28777
  }
}
EOF

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

# apache additional config
cat > /etc/apache2/conf-available/vagrant.conf <<'EOF'
<IfModule mpm_prefork_module>
        MaxRequestWorkers         50
</IfModule>
EOF

# enable mod expires
a2enconf vagrant > /dev/null 2>&1

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
locale-gen fr_FR.utf8 > /dev/null 2>&1
locale-gen es_ES.utf8 > /dev/null 2>&1
locale-gen it_IT.utf8 > /dev/null 2>&1
locale-gen nl_NL.utf8 > /dev/null 2>&1

# enable mod rewrite
a2enmod rewrite > /dev/null 2>&1

# enable mod expires
a2enmod expires > /dev/null 2>&1

#Adding mysql settings
cat > /etc/mysql/conf.d/vagrant.cnf <<'EOF'
[mysqld]

# Innodb per table
innodb_file_per_table=1

#Disable Query Cache
query_cache_type=0

# Allow remote connections to mysql on virtual machine
bind-address = 0.0.0.0

# Skip reverse DNS lookup of clients
skip-name-resolve=ON

# Enable slow
slow-query-log = 1
slow-query-log-file = /var/log/mysql/mysql-slow.log
long_query_time = 2
# log-queries-not-using-indexes


EOF
#Allow mysql root user remote access
mysql -uroot -p1234 -e "GRANT ALL ON *.* to root@'%' IDENTIFIED BY '1234';"
