#
# Cookbook Name: newrelic
# Attributes: default
#

default[:app][:newrelic][:agent_version] = "9.18.1.303"
default[:app][:newrelic][:agent_version_non_docker] = "9.18.1.303-1"
default[:app][:newrelic][:key] = "eu01xx3f388afd41970d6042fc612b81eac2NRAL"
default[:app][:newrelic][:installed]= "false"
default[:app][:newrelic][:app_name]= "#{node[:app][:type]}"