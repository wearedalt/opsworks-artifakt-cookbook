# Author::  Aymeric Matheossian
# Cookbook Name:: php-fpm
# Recipe:: install-docker
#
app_name = node[:app_name]

case node[:app][:type]
when 'orocommerce'
  file_phpIni="oro/commerce/php.ini"
  file_dockerfile="oro/commerce/Dockerfile.erb"
when 'orocrm'
  file_phpIni="oro/crm/php.ini"
  file_dockerfile="oro/crm/Dockerfile.erb"
when 'shopware'
  file_phpIni="shopware/php.ini"
  file_dockerfile="shopware/Dockerfile.erb"
when 'sylius'
  file_phpIni="sylius/php.ini"
  file_dockerfile="sylius/Dockerfile.erb"
when 'magento2'
  file_phpIni="magento2/php.ini"
  file_dockerfile="magento2/Dockerfile.erb"
else
  file_phpIni="php.ini"
  file_dockerfile="Dockerfile.erb"
end

display_title do
  title 'Remove PHP-FPM and PHP from OS'
end
bash "remove_php" do
  code <<-EOH
    yum remove -y php* php-fpm php-cli php-common
    # Remove legacy container and directory
    # CAUTION, Upgrading from 7.4 to 8.* will trigger a downtime then
    if [ "$(docker ps -q -f name=php74fpm -a)" ]; then
      docker stop php74fpm
      docker rm php74fpm
    fi
    if [ -d "/srv/www/php74fpm" ]; then
      rm -rf /srv/www/php74fpm
    fi
  EOH
end

if node[:app][:web_engine] != 'nginx'
  bash "remove_php_module_for_apache" do
    code <<-EOH
      a2dismod php7
      service httpd restart
    EOH
  end
end

display_title do
  title 'Create /var/log/php-fpm'
end
directory "/var/log/php-fpm" do
  action :create
  mode 0755
  owner "apache"
  group "opsworks"
end

display_title do
  title 'Create /var/www/.composer'
end
directory "/var/www/.composer" do
  action :create
  mode 0755
  owner "apache"
  group "opsworks"
end

if node[:app][:sync_ssh_keys] == 'true'
  display_command do
    command "Copy SSH key"
  end
  run_command do
    command 'mkdir -p /srv/www/php/.ssh/ && cp /mnt/shared/.ssh/id_* /srv/www/php/.ssh/'
    user "root"
    group "root"
  end
end

display_title do
  title 'Add /usr/bin/php'
end
template "/usr/bin/php" do
  source "docker/bin/php"
  mode 0755
  group "root"
  owner "root"
end

display_command do
  command "ln -sf /usr/bin/php /usr/local/bin/php"
end
run_command do
  command 'ln -sf /usr/bin/php /usr/local/bin/php'
  user "root"
  group "root"
end


if node[:app][:type] == 'orocommerce'
  display_title do
    title 'Add /usr/bin/node'
  end
  template "/usr/bin/node" do
    source "docker/bin/node"
    mode 0755
    group "root"
    owner "root"
  end

  display_command do
    command "ln -sf /usr/bin/node /usr/local/bin/node"
  end
  run_command do
    command "ln -sf /usr/bin/node /usr/local/bin/node"
    user "root"
    group "root"
  end
end

display_title do
  title 'Add /usr/local/bin/composer'
end
template "/usr/local/bin/composer" do
  source "docker/bin/composer"
  mode 0755
  group "root"
  owner "root"
end

display_title do
  title 'Add /usr/local/bin/n98-magerun'
end
template "/usr/local/bin/n98-magerun" do
  source "docker/bin/n98-magerun"
  mode 0755
  group "root"
  owner "root"
end

display_title do
  title 'Add /usr/local/bin/n98-magerun2'
end
template "/usr/local/bin/n98-magerun2" do
  source "docker/bin/n98-magerun2"
  mode 0755
  group "root"
  owner "root"
end

display_title do
  title "Add directory #{node['php-fpm']['docker_dir']}"
end
directory "#{node['php-fpm']['docker_dir']}" do
  action :create
  mode 0755
  owner "root"
  group "root"
end

display_title do
  title 'Add docker-compose.yml'
end
template "#{node['php-fpm']['docker_dir']}/docker-compose.yml" do
  source "docker/docker-compose.yml.erb"
  mode 0755
  group "root"
  owner "root"
end

display_title do
  title 'Add php.ini'
end
template "#{node['php-fpm']['docker_dir']}/php.ini" do
  source "docker/#{file_phpIni}"
  mode 0755
  group "root"
  owner "root"
end

if node[:app][:type] == 'shopware' || node[:app][:type] == 'magento2'
  display_title do
    title 'Add opcache.exclusion'
  end
  template "#{node['php-fpm']['docker_dir']}/opcache.exclusion" do
    source "docker/#{node['app']['type']}/opcache.exclusion.erb"
    mode 0755
    group "root"
    owner "root"
  end
end


display_title do
  title 'Add www.conf'
end
template "#{node['php-fpm']['docker_dir']}/www.conf" do
  source "docker/www.conf"
  mode 0755
  group "root"
  owner "root"
end

display_title do
  title 'Add Dockerfile'
end
template "#{node['php-fpm']['docker_dir']}/Dockerfile" do
  source "docker/#{file_dockerfile}"
  mode 0755
  group "root"
  owner "root"
end

bash "check_php_fpm_status_and_cleanup_if_exited" do
  user "root"
  cwd "#{node['php-fpm']['docker_dir']}/"
  code <<-EOH
    if [ "$(docker ps -aq -f name=php -f status=exited)" ]; then
        docker-compose down
    fi
  EOH
end

display_command do
  command "docker-compose up -d --build --remove-orphans"
end
run_command do
  command 'docker-compose up -d --build --remove-orphans'
  user "root"
  group "root"
  cwd "#{node['php-fpm']['docker_dir']}/"
end

display_command do
  command "docker system prune -f"
end
run_command do
  command 'docker system prune -f'
  user "root"
  group "root"
  cwd "#{node['php-fpm']['docker_dir']}/"
end