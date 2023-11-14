#
# Cookbook Name: artifakt_app_drupal
# Attributes: default
#

default[:drupal][:document_root] = false
default[:drupal][:shared_directories] = []
default[:drupal][:cached_directories] = []
default[:drupal][:config_file] = {'settings.php.erb' => 'sites/default/settings.php'}
default[:drupal][:files_to_stream] = []
