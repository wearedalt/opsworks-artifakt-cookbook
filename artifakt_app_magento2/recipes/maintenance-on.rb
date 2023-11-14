#
# Cookbook Name: artifakt_app_magento2
# Recipe: maintenance-on
#

node[:deploy].each do |app_name, deploy|
  if node[:opsworks][:main_instance]
    if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]

      display_command do
        command "touch /mnt/shared/var/.maintenance.flag"
      end
      run_command do
        command "touch /mnt/shared/var/.maintenance.flag && chown apache:opsworks /mnt/shared/var/.maintenance.flag"
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