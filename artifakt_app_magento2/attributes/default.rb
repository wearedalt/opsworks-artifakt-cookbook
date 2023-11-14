#
# Cookbook Name: artifakt_app_magento2
# Attributes: default
#

default[:magento2][:document_root] = false
default[:magento2][:shared_directories] = ['pub/media','pub/static/_cache']
default[:magento2][:cached_directories] = ['var/cache','var/page_cache','pub/static/_cache']
default[:magento2][:media_directories] = ['media/catalog/product/cache']
default[:magento2][:log_directories] = ['var/log','var/report']
default[:magento2][:session_directories] = ['var/session']
default[:magento2][:languages] = 'en_US fr_FR'

if ((node[:app][:type] == 'magento2' && node[:app][:version] == '2.4'))
    if node[:stack][:type] != 'standard' 
        default[:magento2][:config_file] = {'env.php.m24.erb' => 'app/etc/env.php'}
    else
        default[:magento2][:config_file] = {'env.php.m24.standard.erb' => 'app/etc/env.php'}
    end
else
    default[:magento2][:config_file] = {'env.php.erb' => 'app/etc/env.php'}
end

default[:magento2][:files_to_stream] = ['var/log/debug.log', 'var/log/exception.log', 'var/log/system.log']