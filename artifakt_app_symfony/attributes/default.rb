#
# Cookbook Name: artifakt_app_symfony
# Attributes: default
#

# Default values is for symfony 4.x
default[:symfony][:document_root] = 'public'
default[:symfony][:media_directories] = []
default[:symfony][:shared_directories] = [ 'public/uploads','var/log' ]
default[:symfony][:cached_directories] = [ 'var/cache' ]
default[:symfony][:log_directories] = [ 'var/log' ]
default[:symfony][:session_directories] = []
default[:symfony][:config_file] = {'parameters.yml.erb' => 'config/parameters.yml'}
default[:symfony][:files_to_stream] = ['var/log/prod.log', 'var/log/dev.log']

# Symfony version 3.x
if node[:app][:version].slice(0..0) == '3'
  default[:symfony][:document_root] = 'web'
  default[:symfony][:shared_directories] = [ 'app/uploads','web/uploads','var/logs' ]
  default[:symfony][:log_directories] = [ 'var/logs' ]
  default[:symfony][:session_directories] = []
  default[:symfony][:config_file] = {'parameters.yml.erb' => 'app/config/parameters.yml'}
  default[:symfony][:files_to_stream] = ['var/logs/prod.log', 'var/logs/dev.log']
end
