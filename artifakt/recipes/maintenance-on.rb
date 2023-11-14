#
# Cookbook Name: artifakt
# Recipe: maintenance-on
#

include_recipe "artifakt_app_#{node[:app][:type]}::maintenance-on"
