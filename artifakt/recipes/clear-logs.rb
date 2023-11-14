#
# Cookbook Name: artifakt
# Recipe: clear-logs
#

app_type = node[:app][:type]

node[app_type][:log_directories].each do |directory_to_delete|
  execute 'Remove log files' do
    user 'root'
    cwd "/mnt/shared/"
    command "rm -rf #{directory_to_delete}/*"
  end
end