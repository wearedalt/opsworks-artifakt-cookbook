#
# Cookbook Name: artifakt_htpasswd
# Recipe: enabled
#

execute "Create htpasswd" do
 command "htpasswd -cb #{node['htpasswd']['path']} '#{node['htpasswd']['username']}' '#{node['htpasswd']['password']}'"
end

include_recipe "mod_php5_apache2"
include_recipe "mod_php5_apache2::php"