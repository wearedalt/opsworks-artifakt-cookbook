#
# Cookbook Name: artifakt
# Definition: artifakt_file_shared
#

define :artifakt_file_shared, :filename => nil do
  release_path = node[:app_release_path]
  file_name = params[:filename]

  bash "Mount file" do
    user "root"
    code <<-EOH
      touch /mnt/shared/#{file_name}
      rm -f #{release_path}/#{file_name}
      ln -s /mnt/shared/#{file_name} #{release_path}/#{file_name}
      chmod 777 /mnt/shared/#{file_name}
      chown #{node[:app_user]}:#{node[:app_group]} /mnt/shared/#{file_name}
    EOH
  end

end