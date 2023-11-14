map_file_path = "#{node[:deploy][:magento][:absolute_code_root]}/artifakt/map_#{node[:environment_code]}.conf"
map_file_escapted_path = map_file_path.gsub("/", "\\/")

display_title do
  title "Check and refresh NGINX map file if needed"
end

bash "Check and refresh NGINX map file if needed" do
  user "root"
  cwd "#{node[:deploy][:magento][:absolute_code_root]}/"
  code <<-EOH
    if [ -f "/etc/nginx/sites-available/magento" ]; then
      if [ -f "artifakt/map_#{node[:environment_code]}.conf" ]; then
        sed -i "s/#MAP_FILE_PLACEHOLDER/include #{map_file_escapted_path};/" /etc/nginx/sites-available/magento
        sed -i '/set $MAGE_RUN_CODE/d' /etc/nginx/sites-available/magento
      else
        sed -i "s/include #{map_file_escapted_path};/#MAP_FILE_PLACEHOLDER/" /etc/nginx/sites-available/magento
        if [[ -z $(grep 'set $MAGE_RUN_CODE "";' "/etc/nginx/sites-available/magento") ]]; then
         sed -i '/root $MAGE_ROOT\\/pub;/iset $MAGE_RUN_CODE "";' /etc/nginx/sites-available/magento
        fi
      fi
      if [ ! -L "/etc/nginx/sites-enabled/magento" ]; then
        ln -sf /etc/nginx/sites-available/magento /etc/nginx/sites-enabled
      fi
    fi
    EOH
end