#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008, OpsCode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

app_name = node[:app_name]
display_title do
  title 'Remove httpd service'
end
bash "Stop and uninstall httpd" do
  code <<-EOH
  service stop httpd
  yum remove -y httpd
  EOH
end

display_title do
  title 'Installation of NGINX'
end

package "nginx" do
  retries 3
  retry_delay 5
end

display_title do
  title 'Configuration of NGINX'
end

directory node[:nginx][:dir] do
  owner 'root'
  group 'root'
  mode '0755'
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{sites-available sites-enabled conf.d}.each do |dir|
  directory File.join(node[:nginx][:dir], dir) do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{node[:nginx][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner "root"
  group "root"
  mode 0644
end

if node[:app][:type]=='phpapp'
  display_title do
    title 'Php app detected, set default vhost for nginx'
  end

  if (node[:app][:language] == "74" || node[:app][:language][0] == "8")
    template "/etc/nginx/sites-available/default" do
      source "default-php-docker.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :environment => OpsWorks::Escape.escape_double_quotes(node[:deploy][app_name][:environment_variables])
      )
    end
  else
    template "/etc/nginx/sites-available/default" do
      source "default-php.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :environment => OpsWorks::Escape.escape_double_quotes(node[:deploy][app_name][:environment_variables])
      )
    end
  end

  execute 'add vhost' do
    command "ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled"
  end
  service "nginx" do
    action :reload
  end
end

if node[:app][:type]=='magento2'
  if (node[:app][:language] == "74" || node[:app][:language][0] == "8")
    template "/etc/nginx/sites-available/magento" do
      source "magento2_docker.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :environment => OpsWorks::Escape.escape_double_quotes(node[:deploy][app_name][:environment_variables])
      )
    end
  else
    template "/etc/nginx/sites-available/magento" do
      source "magento2.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :environment => OpsWorks::Escape.escape_double_quotes(node[:deploy][app_name][:environment_variables])
      )
    end
  end

  bash "update_nginx_config_if_varnish" do
    code <<-EOH
      if [ "$(docker ps -q -f name=varnish -a)" ]; then
        sed -i -e "s/listen 80;/listen 8080;/g" /etc/nginx/sites-available/magento
      fi
    EOH
  end
  execute 'add vhost' do
    command "ln -sf /etc/nginx/sites-available/magento /etc/nginx/sites-enabled"
  end
end

if node[:app][:type] == 'magento'
  template "/etc/nginx/sites-available/magento" do
    source "magento.erb"
    owner "root"
    group "root"
    mode 0644
  end
  execute 'add vhost' do
    command "ln -sf /etc/nginx/sites-available/magento /etc/nginx/sites-enabled"
  end
end

if node[:app][:type] == 'orocommerce'
  template "/etc/nginx/sites-available/orocommerce" do
    source "orocommerce.erb"
    owner "root"
    group "root"
    mode 0644
  end
  execute 'add vhost' do
    command "ln -sf /etc/nginx/sites-available/orocommerce /etc/nginx/sites-enabled"
  end
end

if node[:app][:type] == 'orocrm'
  template "/etc/nginx/sites-available/orocrm" do
    source "orocrm.erb"
    owner "root"
    group "root"
    mode 0644
  end
  execute 'add vhost' do
    command "ln -sf /etc/nginx/sites-available/orocrm /etc/nginx/sites-enabled"
  end
end

if node[:app][:type] == 'shopware'
  template "/etc/nginx/sites-available/shopware" do
    source "shopware.erb"
    owner "root"
    group "root"
    mode 0644
  end
  execute 'add vhost' do
    command "ln -sf /etc/nginx/sites-available/shopware /etc/nginx/sites-enabled"
  end
end

if node[:app][:type] == 'sylius'
  template "/etc/nginx/sites-available/sylius" do
    source "sylius.erb"
    owner "root"
    group "root"
    mode 0644
  end
  execute 'add vhost' do
    command "ln -sf /etc/nginx/sites-available/sylius /etc/nginx/sites-enabled"
  end
end

if node[:url][:secure] == 'true'
  template "/etc/nginx/fastcgi.conf" do
    source "fastcgi.conf.erb"
    owner "root"
    group "root"
    mode 0644
  end
end

include_recipe "nginx::service"

display_title do
  title 'Enable NGINX service'
end

service "nginx" do
  action [ :enable, :start ]
end

execute 'add permission' do
  command "chown -R #{node[:nginx][:user]}:root /var/lib/nginx"
end

template "/etc/logrotate.d/nginx" do
  backup false
  source "logrotate.erb"
  owner "root"
  group "root"
  mode 0644
end
