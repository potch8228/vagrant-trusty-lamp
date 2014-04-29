#
# Cookbook Name:: lamp-stack
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "apt-get-update" do
    command "apt-get update"
end

%w{apache2 mysql-server mysql-client php5 php5-mysql}.each do |pkg|
    package pkg do
        action :install
    end
end

service "apache2" do
    action [ :enable, :start ]
    supports :restart => true
end

template "/etc/apache2/apache2.conf" do
    owner "root"
    group "root"
    mode 0644
end

execute "mod_rewrite" do
    command "a2enmod rewrite"
    notifies :restart, "service[apache2]", :immediately
end

directory '/var/www' do
    recursive true
    action :delete
end

link '/var/www' do
    to '/vagrant'
end
