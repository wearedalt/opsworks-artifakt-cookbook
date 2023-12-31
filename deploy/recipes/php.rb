#
# Cookbook Name:: deploy
# Recipe:: php
#

include_recipe 'deploy'

if node[:app][:web_engine] != 'nginx'
  include_recipe "mod_php5_apache2"
  include_recipe "mod_php5_apache2::php"
end

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end

