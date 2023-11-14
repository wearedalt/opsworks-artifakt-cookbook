#
# Cookbook Name: artifakt_app_akeneo
# Attributes: default
#

# Default values for Akeneo 4.x & 5.x
if node[:app][:version].slice(0..0) == '4' || node[:app][:version].slice(0..0) == '5'
  default[:akeneo][:document_root] = 'public'
  default[:akeneo][:shared_directories] = ['var/uploads', 'var/logs', 'var/file_storage', 'public/uploads', 'public/media']
  default[:akeneo][:cached_directories] = ['var/cache']
  default[:akeneo][:media_directories] = []
  default[:akeneo][:log_directories] = []
  default[:akeneo][:session_directories] = []
  default[:akeneo][:config_file] = {'env.yml.erb' => '.env.artifakt'}
  default[:akeneo][:files_to_stream] = ['var/logs/prod.log', 'var/logs/dev.log']
  default[:akeneo][:version_es] = 7

  if node[:app][:version].slice(0..0) == '4'
    default[:akeneo][:version_node] = 10
  end

  if node[:app][:version].slice(0..0) == '5'
    default[:akeneo][:version_node] = 12
  end
end

# Default values for Akeneo 3.x
if node[:app][:version].slice(0..0) == '3'
  default[:akeneo][:document_root] = 'web'
  default[:akeneo][:shared_directories] = [ 'web/uploads','app/uploads','app/archive','app/import','app/export','web/import','web/export','app/file_storage','app/logs' ]
  default[:akeneo][:cached_directories] = [ 'app/cache' ]
  default[:akeneo][:media_directories] = []
  default[:akeneo][:log_directories] = []
  default[:akeneo][:session_directories] = []
  default[:akeneo][:config_file] = {'parameters.yml.erb' => 'app/config/parameters.yml'}
  default[:akeneo][:files_to_stream] = ['app/logs/prod.log', 'app/logs/dev.log']
  default[:akeneo][:version_es] = 6
  default[:akeneo][:version_node] = 10
end
