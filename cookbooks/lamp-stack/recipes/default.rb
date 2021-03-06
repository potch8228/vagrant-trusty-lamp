#
# Cookbook Name:: lamp-stack
# Recipe:: default
#
# Copyright 2014, Healthcare Style Laboratory
#
# All rights reserved - Do Not Redistribute
#

execute "apt-get-update" do
    command "apt-get update"
end

package "apache2" do
    action :install
end

%w{php5 php5-mysql php5-dev php5-curl phpunit php5-apcu php5-memcached php5-memcache php5-mcrypt php5-gd}.each do |pkg|
    package pkg do
        action :install
    end
end

execute "xdebug" do
    command "pecl install xdebug"
    not_if "pecl list | grep xdebug"
end

script "install_php_cli_apc" do
    interpreter "bash"
    user "root"
    cwd  "/etc/php5/mods-available/"
    code <<-EOD
    APC_INI=apcu.ini
    echo "apc.enable_cli = 1" | tee -a $APC_INI
    EOD
    not_if "cat /etc/php5/mods-avaliable/apcu.ini | grep apc.enable_cli"
end

# script "install_xdebug" do
#     interpreter "bash"
#     user "root"
#     cwd  "/etc/php5/"
#     code <<-EOD
#     PHP_INI=php.ini
#     XDEBUG_PATH=`find / -name 'xdebug.so'`
#     echo "zend_extension = \"${XDEBUG_PATH}\"" | tee -a apache2/$PHP_INI cli/$PHP_INI
#     EOD
#     not_if "cat /etc/php5/apache2/php.ini | grep xdebug"
# end

%w{mysql-server mysql-client}.each do |pkg|
    package pkg do
        action :install
    end
end

template "/etc/mysql/my.cnf" do
    owner "root"
    group "root"
    mode 0644
    not_if "cat /etc/mysql/my.cnf | grep character-set-server"
end

execute "mysql_restart" do
    command "service mysql restart"
end

template "/etc/apache2/apache2.conf" do
    owner "root"
    group "root"
    mode 0644
    not_if "/etc/apache2/apache2.conf | grep AllowOverride | grep All"
end

template "/etc/apache2/envvars" do
    owner "root"
    group "root"
    mode 0644
    not_if "/etc/apache2/envvars | grep vagrant"
end

execute "php5enmod mcrypt" do
    action :run
end

execute "mod_rewrite" do
    command "a2enmod rewrite"
end

execute "mod_ssl" do
    command "a2enmod ssl"
end

execute "a2ensite default-ssl" do
    command "a2ensite default-ssl"
end

execute "apache2_restart" do
    command "service apache2 restart"
end

directory "/var/www" do
    recursive true
    action :delete
    not_if "test -h /var/www"
end

link "/var/www" do
    to "/vagrant"
    not_if "test -e /var/www"
end
