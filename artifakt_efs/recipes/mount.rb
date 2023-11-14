#
# Cookbook Name: artifakt_efs
# Recipe: mount
# Edit: 2020-09-01- Aymeric MATHEOSSIAN / Use chef command to check if the volume is already mounted and add mount to fstab

display_title do
  title 'Mounting EFS file system'
end

Chef::Log.info('Mount EFS Service')

package 'Install NFS' do
  case node[:platform]
  when 'ubuntu'
    package_name 'nfs-common'
  else
    package_name 'nfs-utils'
  end
end

# Gives rights to the efs path
directory node['efs']['path'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Mount the volume with the chef command
mount node['efs']['path'] do
  device node['efs']['domain']
  fstype 'nfs4'
  options 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2'
  action [:mount, :enable]
end
