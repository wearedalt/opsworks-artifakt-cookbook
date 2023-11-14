#
# Cookbook Name: artifakt
# Recipe: clear-session
#

app_type = node[:app][:type]

node[app_type][:session_directories].each do |directory_to_delete|
  execute 'Remove session files' do
    user 'root'
    cwd "/mnt/shared/"
    command "rm -rf #{directory_to_delete}/*"
  end
end