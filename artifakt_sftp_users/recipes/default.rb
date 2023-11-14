#
# Cookbook Name: artifakt_sftp_users
# Recipe: default
#

require 'digest/sha2'

if node[:stack][:isScalable] == 'true'
  include_recipe 'artifakt_efs::mount'
end

display_title do
  title 'Creation of sftp users'
end

chef_gem "ruby-shadow"

gem_package "ruby-shadow" do
  action :install
end

Chef::Log.info("Create group #{node[:sftp][:group]}")
group node[:sftp][:group]

Chef::Log.info('Change sshd config')
template '/etc/ssh/sshd_config' do
  source 'sshd_config.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
      :sftpgroup => node[:sftp][:group]
  )
end

sftpusers = {}

if node[:sftp_users]!= nil

  node[:sftp_users].each do |userName, userInfo|

    sftpusers[userName] = userName

    password = userInfo['password']
    salt = rand(36**8).to_s(36)
    shadow_hash = password.crypt("$6$" + salt)

    Chef::Log.info("setting up SFTP user #{userName}")
    user userName do
      action :create
      comment "SFTP user #{userName}"
      non_unique true
      uid  '48'
      gid node[:sftp][:group]
      password shadow_hash
      home "/home/#{userName}"
      supports :manage_home => true
      shell '/bin/bash'
    end

    Chef::Log.info("Change permission home for user #{userName}")
    directory "/home/#{userName}" do
      owner 'root'
      group 'root'
      mode 0755
    end

    Chef::Log.info("Add user #{userName} in SFTP group")
    group node[:sftp][:group] do
      action :modify
      members userName
      append true
    end

    if userInfo['folders'] != nil
      if userInfo['folders'].empty?

        Chef::Log.info("Add mount shared for user #{userName}")
        directory "/mnt/shared" do
          owner 'apache'
          group 'opsworks'
          mode 0777
          action :create
        end

        directory "/home/#{userName}/shared" do
          owner 'apache'
          group 'opsworks'
          mode 0777
          action :create
        end

        mount "/home/#{userName}/shared" do
          device '/mnt/shared'
          action [:mount, :enable]
          options 'rw,bind'
        end
      else
        userInfo['folders'].each do |destination|

          source = "/mnt/shared/#{destination}"

          Chef::Log.info("Add mount path #{source} for user #{userName}")
          if File.exists?(source)
            directory "/home/#{userName}/#{destination}" do
              owner 'apache'
              group 'opsworks'
              recursive true
              mode 0777
              action :create
            end

            mount "/home/#{userName}/#{destination}" do
              device source
              action [:mount, :enable]
              options 'rw,bind'
            end
          else
            Chef::Log.warn("Folder #{source} does not exist - can not mount it to chrooted home of user #{userName}")
          end
        end
      end
    end
  end
end

Chef::Log.info('Remove deleted sftp users')
(node[:passwd] || node[:etc][:passwd]).each do |username, entry|
  if entry[:gid] == node[:sftp_gid]
    unless sftpusers.has_key?(username)
      Chef::Log.info("Remove SFTP user #{username}")

      execute "umount all point of user #{username}" do
        command "mount | grep /home/#{username}/ | awk '{ print $3 }' | xargs -r umount"
      end

      execute "kill all processes of user #{username}" do
        command "pkill -u #{username}; true"
      end

      execute "Force user #{username} deletion" do
        command "userdel -f #{username}"
      end
    end
  end
end

service "sshd" do
  service_name value_for_platform_family(
     'rhel' => 'sshd',
     'debian' => 'ssh'
  )
  action :restart
end
