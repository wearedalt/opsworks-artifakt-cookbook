#
# Cookbook Name: artifakt
# Recipe: clear-server
#

app_type = node[:app][:type]

execute 'Remove server tmp files' do
  user 'root'
  command "rm -rf /tmp/*"
end
