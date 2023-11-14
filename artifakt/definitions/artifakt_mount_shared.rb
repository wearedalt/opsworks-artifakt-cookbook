#
# Cookbook Name: artifakt
# Definition: artifakt_mount_shared
#

define :artifakt_mount_shared, :dirname => nil do
  release_path = node[:app_release_path]
  directory_name = params[:dirname]

  bash "Mount directory" do
    user "root"
    code <<-EOH
      mkdir -p /mnt/shared/#{directory_name}
      rm -rf #{release_path}/#{directory_name}
      ln -s /mnt/shared/#{directory_name}/ #{release_path}/#{directory_name}
      chmod 777 /mnt/shared/#{directory_name}
      chown #{node[:app_user]}:#{node[:app_group]} /mnt/shared/#{directory_name}
    EOH
  end

end