#
# Cookbook Name: artifakt_app_symfony
# Attributes: default
#

# Default values is for symfony 4.x
default[:orocrm][:document_root] = 'public'
default[:orocrm][:media_directories] = []
default[:orocrm][:shared_directories] = [ 'public/uploads','var/log' ]
default[:orocrm][:cached_directories] = [ 'var/cache' ]
default[:orocrm][:log_directories] = [ 'var/logs' ]
default[:orocrm][:session_directories] = []
default[:orocrm][:config_file] = {'parameters.yml.erb' => 'config/parameters.yml'}
default[:orocrm][:files_to_stream] = ['var/logs/prod.log', 'var/logs/dev.log']

