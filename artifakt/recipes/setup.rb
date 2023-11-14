#
# Cookbook Name: artifakt
# Recipe: setup
#
display_text do
  text 'COOKBOOK - Artifakt / recipes / setup.rb'
end

include_recipe 'artifakt_certificates'
include_recipe 'artifakt_runtime_config'

display_title do
  title 'App type: '+node[:app][:type]+' / App version: '+node[:app][:version]+' / PHP version: '+node[:app][:language]+' / Stack type: '+node[:stack][:type]
end

include_recipe 'artifakt_logs::install'
include_recipe 'artifakt_cloudwatchagent::setup'
if node[:stack][:isScalable] == 'true'
    include_recipe 'artifakt_efs::mount'
end

node.default[:command][:type] = 'setup'

include_recipe 'artifakt_docker::install'
include_recipe 'artifakt_htpasswd::setup'
if node[:app][:web_engine] == 'nginx'
  include_recipe 'nginx'
  include_recipe 'php-fpm'
  include_recipe 'mod_php5_apache2::mysql_adapter'
else
  include_recipe 'mod_php5_apache2'
  if (node[:app][:language] == "74" || node[:app][:language][0] == '8')
    include_recipe 'php-fpm'
  end
end

include_recipe 'artifakt_elasticsearch::install'
include_recipe 'artifakt_rabbitmq::install'
include_recipe 'artifakt_supervisor::install'
include_recipe 'artifakt_redis::install'
include_recipe 'artifakt_newrelic::install'
include_recipe 'artifakt_crontab::install'
include_recipe 'artifakt_crontab::setup'
include_recipe 'artifakt_varnish::install'
include_recipe 'ssh_users'
include_recipe 'artifakt_sftp_users'

if node[:quanta][:token]
  display_title do
    title 'Installation Quanta agent'
  end
  
  include_recipe 'artifakt_quanta::setup'
end

display_title do
  title 'Configuration of php.ini'
end

template "/etc/php.ini" do
    source "php.ini.erb"
    mode 0777
    group "root"
    owner "root"
end

if node[:email][:type] == 'no_send'
    package 'sendmail' do
      action :remove
    end
end

# This is already available in the PHP-FPM Docker container
if (node[:app][:language] != "74" && node[:app][:language][0] != '8')
  include_recipe 'artifakt_composer::install'
end
include_recipe "artifakt_app_#{node[:app][:type]}::setup"
