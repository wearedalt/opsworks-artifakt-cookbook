#
# Cookbook Name: artifakt
# Recipe: clear-cache
#

include_recipe 'artifakt_runtime_config'

app_type = node[:app][:type]

display_title do
  title "Clear cache directories of #{app_type}"
end

node[app_type][:cached_directories].each do |directory_to_delete|
  execute 'Remove cache files' do
    user 'root'
    cwd "/mnt/shared/"
    command "rm -rf #{directory_to_delete}/*"
  end

  display_text do
    text "#{directory_to_delete}/* flushed"
  end
end

if app_type == 'magento2'
  display_title do
    title "Running custom flush cache command of magento2"
  end
  display_command do
    command "php bin/magento cache:flush"
  end
  run_command do
    command 'php bin/magento cache:flush'
    user node[:deploy]["magento"][:user]
    group node[:deploy]["magento"][:group]
    environment node[:deploy][node[:app_name]][:environment_variables]
    cwd "#{node[:deploy][:magento][:absolute_code_root]}/"
  end
end

if app_type == 'magento'
  display_title do
    title "Running custom flush cache command of magento 1"
  end
  display_command do
    command "n98-magerun cache:flush"
  end
  run_command do
    command 'n98-magerun cache:flush'
    user node[:deploy]["magento"][:user]
    group node[:deploy]["magento"][:group]
    environment node[:deploy][node[:app_name]][:environment_variables]
    cwd "#{node[:deploy][:magento][:absolute_code_root]}/"
  end
end

if node[:app][:web_engine] == 'nginx'
  display_title do
    title "Restart Nginx + PHP-FPM"
  end
  service "nginx" do
    action :restart
  end

  if (node[:app][:language] != "74" && node[:app][:language][0] != '8')
    service "php-fpm" do
        action :restart
    end
  end
else
  display_title do
    title "Restart Apache2"
  end
  service "httpd" do
    action :restart
  end
end

if (node[:app][:language] == "74" || node[:app][:language][0] == '8')
  include_recipe 'php-fpm::restart-docker'
end
