#
# Cookbook Name: artifakt_app_magento
# Attributes: default
#

default[:magento][:document_root] = false
default[:magento][:shared_directories] = [ 'media','var' ]
default[:magento][:cached_directories] = [ 'var/cache','var/full_page_cache','media/css','media/css_secure','media/js','media/js_secure' ]
default[:magento][:media_directories] = ['media/catalog/product/cache']
default[:magento][:log_directories] = ['var/log','var/report']
default[:magento][:session_directories] = ['var/session']
default[:magento][:config_file] = {'local.xml.erb' => 'app/etc/local.xml'}
default[:magento][:files_to_stream] = ['var/log/debug.log', 'var/log/exception.log', 'var/log/system.log']
