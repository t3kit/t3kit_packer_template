# t3kit_packer_template

Packer configuration to create the vagrant box "t3kit/t3kit".

It's based on ubuntu-14.04.3-server-amd64 with LAMP and some other tools and configurations for apache, mysql and php. 

**It should only be used as a development environment!**

Docroot is set to /var/www/shared/site. 

It is not a safe installation, mysql is bind to 0.0.0.0 and mysql root user is allowed to connect from "everywhere", so it is possible to connect to mysql from the host.
```ruby
config.vm.network "forwarded_port", guest: 3306, host: 3307
```
Mailcatcher is installed and listens on port 1080.
```ruby
config.vm.network "forwarded_port", guest: 1080, host: 1080
```