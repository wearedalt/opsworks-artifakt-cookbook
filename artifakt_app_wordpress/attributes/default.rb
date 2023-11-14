#
# Cookbook Name: artifakt_app_wordpress
# Attributes: default
#

default[:wordpress][:disable_wp_cron] = "false"
default[:wordpress][:document_root] = false
default[:wordpress][:shared_directories] = [ 'wp-content/cache','wp-content/uploads','wp-content/backups','wp-content/backup-db','wp-content/upgrade' ]
default[:wordpress][:cached_directories] = [ 'wp-content/cache' ]
default[:wordpress][:media_directories] = []
default[:wordpress][:log_directories] = []
default[:wordpress][:session_directories] = []
default[:wordpress][:config_file] = {'wp-config.php.erb' => 'wp-config.php'}
default[:wordpress][:files_to_stream] = []
