#
# Cookbook Name: artifakt
# Recipe: install
#

include_recipe "artifakt_app_#{node[:app][:type]}::install"

node[:deploy].each do |app_name, deploy|
  execute 'Execute custom install script' do
    user 'root'
    cwd "#{deploy[:deploy_to]}/current/"
    command 'sh artifakt/install.sh'
    only_if { File.exist?("#{deploy[:deploy_to]}/current/artifakt/install.sh") }
  end
end