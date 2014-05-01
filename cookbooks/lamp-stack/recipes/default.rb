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

#service "apache2" do
##    action [ :enable, :start ]
#    action :nothing
#    supports :restart => true
#end

%w{php5 php5-mysql php5-dev php5-curl}.each do |pkg|
    package pkg do
        action :install
    end
end

execute "xdebug" do
    command "pecl install xdebug"
    not_if "pecl list | grep xdebug"
end

script "install_xdebug" do
    interpreter "bash"
    user "root"
    cwd  "/etc/php5/"
    code <<-EOD
    PHP_INI=php.ini
    XDEBUG_PATH=`find / -name 'xdebug.so'`
    echo "zend_extension = \"${XDEBUG_PATH}\"" | tee -a apache2/$PHP_INI cli/$PHP_INI
    EOD
    not_if "cat /etc/php5/apache2/php.ini | grep xdebug"
end

%w{mysql-server mysql-client}.each do |pkg|
    package pkg do
        action :install
    end
end

# service "mysql" do
#     action :nothing
#     supports :restart => true
# end

template "/etc/mysql/my.cnf" do
    owner "root"
    group "root"
    mode 0644
    not_if "cat /etc/mysql/my.cnf | grep character-set-server"
#    notifies :restart, "service[mysql]", :immediately
end

execute "mysql_restart" do
    command "service mysql restart"
end

#service "apache2" do
##    action [ :enable, :start ]
#    action :nothing
#    supports :restart => true
#end

template "/etc/apache2/apache2.conf" do
    owner "root"
    group "root"
    mode 0644
    not_if "/etc/apache2/apache2.conf | grep AllowOverride | grep All"
end

execute "mod_rewrite" do
    command "a2enmod rewrite"
#    notifies :restart, "service[apache2]", :immediately
end

execute "apache2_restart" do
    command "service apache2 restart"
end

directory '/var/www' do
    recursive true
    action :delete
end

link '/var/www' do
    to '/vagrant'
end
