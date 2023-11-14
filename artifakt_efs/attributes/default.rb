#
# Cookbook Name: artifakt_efs
# Attributes: default
#

default[:efs][:path] = '/mnt/shared'
default[:efs][:domain] = "#{node[:opsworks][:instance][:availability_zone]}.#{node[:efs][:name]}.efs.#{node[:network][:region]}.amazonaws.com:/"
