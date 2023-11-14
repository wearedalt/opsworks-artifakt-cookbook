# Author::  Aymeric Matheossian
# Cookbook Name:: php-fpm
# Recipe:: restart-docker
#

display_title do
  title 'Restart PHP-FPM Docker container'
end

display_command do
  command "docker-compose restart"
end
run_command do
  command 'docker-compose restart'
  user "root"
  group "root"
  cwd "#{node['php-fpm']['docker_dir']}/"
end
