#
# Cookbook Name: artifakt
# Recipe: maintenance-off
#

include_recipe "artifakt_app_#{node[:app][:type]}::maintenance-off"
