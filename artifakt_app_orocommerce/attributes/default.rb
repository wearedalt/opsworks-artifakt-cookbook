#
# Cookbook Name: artifakt_app_symfony
# Attributes: default
#

# Default values is for symfony 4.x
default[:orocommerce][:document_root] = 'public'
default[:orocommerce][:media_directories] = []
default[:orocommerce][:shared_directories] = [ 'public/uploads','var/log' ]
default[:orocommerce][:cached_directories] = [ 'var/cache' ]
default[:orocommerce][:log_directories] = [ 'var/logs' ]
default[:orocommerce][:session_directories] = []
default[:orocommerce][:config_file] = {'parameters.yml.erb' => 'config/parameters.yml'}
default[:orocommerce][:files_to_stream] = ['var/logs/prod.log', 'var/logs/dev.log']

