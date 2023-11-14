#
# Cookbook Name: artifakt_htpasswd
# Attributes: default
#

default[:htpasswd][:enabled] = false
default[:htpasswd][:path] = '/srv/www/.htpasswd'
default[:htpasswd][:name] = 'Artifakt.io restrict this content'
default[:htpasswd][:username] = 'username'
default[:htpasswd][:password] = 'password'
