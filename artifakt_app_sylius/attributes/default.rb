#
# Cookbook Name: artifakt_app_sylius
# Attributes: default
#

# Default values is for sylius
default[:sylius][:document_root] = 'public'
default[:sylius][:media_directories] = []
default[:sylius][:shared_directories] = [ 'public/uploads','public/media','var/log','var/sessions','config/jwt' ]
default[:sylius][:cached_directories] = [ 'var/cache' ]
default[:sylius][:log_directories] = [ 'var/log' ]
default[:sylius][:session_directories] = [ 'var/sessions' ]
default[:sylius][:config_file] = {'env.erb' => '.env'}
default[:sylius][:files_to_stream] = ['var/log/prod.log', 'var/log/dev.log']
default[:sylius][:version_node] = 14