#
# Cookbook Name: artifakt_htpasswd
# Recipe: setup
#

if node[:htpasswd][:enabled] == 'true'
  execute "Create htpasswd" do
    command "htpasswd -cb #{node['htpasswd']['path']} '#{node['htpasswd']['username']}' '#{node['htpasswd']['password']}'"
  end
else
  file node['htpasswd']['path'] do
    action :delete
  end
end
