#
# Cookbook Name: artifakt
# Recipe: configure
#

include_recipe 'php::configure'
include_recipe 'artifakt_varnish::configure'
