#
# Cookbook Name: artifakt_app_shopware
# Attributes: default
#

# Default values is for shopware
default[:shopware][:document_root] = 'public'
default[:shopware][:media_directories] = []
default[:shopware][:shared_directories] = [ 'custom/plugins','files','public/bundles','public/sitemap', 'public/theme','public/thumbnail','public/uploads','public/media','var/log','config/jwt' ]
default[:shopware][:cached_directories] = [ 'var/cache' ]
default[:shopware][:log_directories] = [ 'var/log' ]
default[:shopware][:session_directories] = []
default[:shopware][:config_file] = {'env.erb' => '.env'}
default[:shopware][:files_to_stream] = ['var/log/prod.log', 'var/log/dev.log']