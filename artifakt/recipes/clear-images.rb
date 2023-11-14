#
# Cookbook Name: artifakt
# Recipe: clear-images
#

app_type = node[:app][:type]

node[app_type][:media_directories].each do |directory_to_delete|
  execute 'Remove cache media files' do
    user 'root'
    cwd "/mnt/shared/"
    command "rm -rf #{directory_to_delete}/*"
  end
end