#
# Cookbook Name: artifakt_app_magento2
# Recipe: setup
#

if (node[:app][:type] != 'magento2' && node[:app][:version] != '2.4')
  bash "Install N98" do
    user "root"
    code <<-EOH
        wget https://files.magerun.net/n98-magerun2.phar
        mv n98-magerun2.phar /usr/local/bin/n98-magerun2
        chmod +x /usr/local/bin/n98-magerun2
    EOH
  end
end

if node[:app][:language] == "72" || node[:app][:language] == "73"
  bash "OPcache configuration" do
    user "root"
    code <<-EOH
      bash -c "echo opcache.enable=1 > /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.enable_cli=0 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.memory_consumption=512 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.interned_strings_buffer=16 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.max_accelerated_files=100000 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.validate_timestamps=0 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.consistency_checks=0 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.enable_file_override=1 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.save_comments=1 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"
      bash -c "echo opcache.fast_shutdown=0 >> /etc/php-#{node[:app][:language_long]}.d/zz-opcache.ini"

      bash -c "echo #{node[:deploy][:magento][:absolute_code_root]}/app/etc/env.php > /etc/php-#{node[:app][:language_long]}.d/opcache-magento2.blacklist"
      bash -c "echo #{node[:deploy][:magento][:absolute_code_root]}/app/etc/config.php >> /etc/php-#{node[:app][:language_long]}.d/opcache-magento2.blacklist"
    EOH
  end
end


