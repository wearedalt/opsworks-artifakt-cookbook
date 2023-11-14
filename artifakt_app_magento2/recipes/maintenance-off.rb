#
# Cookbook Name: artifakt_app_magento2
# Recipe: maintenance-off
#

node[:deploy].each do |app_name, deploy|
  if node[:opsworks][:main_instance]
    if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]

      display_command do
        command "rm /mnt/shared/var/.maintenance.flag"
      end
      run_command do
        command "rm /mnt/shared/var/.maintenance.flag"
      end

      display_command do
        command "php bin/magento cache:flush full_page"
      end
      run_command do
        command 'php bin/magento cache:flush full_page'
        cwd "#{node[:deploy][app_name][:absolute_code_root]}"
      end
    end
  end
end