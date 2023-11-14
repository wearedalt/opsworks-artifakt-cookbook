#
# Cookbook Name: artifakt_htpasswd
# Recipe: disabled
#

include_recipe "mod_php5_apache2"
include_recipe "mod_php5_apache2::php"

file node['htpasswd']['path'] do
  action :delete
end