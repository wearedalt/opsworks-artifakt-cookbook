module OpsWorks
  module User

    def load_existing_ssh_users
      return {} unless node[:opsworks_gid]

      existing_ssh_users = {}
      (node[:passwd] || node[:etc][:passwd]).each do |username, entry|
        if entry[:gid] == node[:opsworks_gid]
            if username != 'apache'
              existing_ssh_users[username] = username
            end
        end
      end
      existing_ssh_users
    end

    def load_existing_users
      existing_users = {}
      (node[:passwd] || node[:etc][:passwd]).each_key do |username|
        existing_users[username] = username
      end
      existing_users
    end

    def setup_user(params)
      existing_users = load_existing_users
      if existing_users.has_value?(params[:name])
        Chef::Log.info("Username #{params[:name]} is taken, not setting up user #{params[:name]}")
      else
        Chef::Log.info("setting up user #{params[:name]}")
        user params[:name] do
          action :create
          comment "OpsWorks user #{params[:name]}"
          non_unique true
          uid '48'
          gid 'opsworks'
          home "/home/#{params[:name]}"
          supports :manage_home => true
          shell '/bin/bash'
        end

        directory "/home/#{params[:name]}/.ssh" do
          owner params[:name]
          group 'opsworks'
          mode 0700
        end

        set_public_key(params)
      end
    end

    def set_public_key(params)
      Chef::Log.info("setting public key for user #{params[:name]}")
      template "/home/#{params[:name]}/.ssh/authorized_keys" do
        cookbook 'ssh_users'
        source 'authorized_keys.erb'
        owner params[:name]
        group 'opsworks'
        variables(:public_key => params[:public_key])
        only_if do
          File.exists?("/home/#{params[:name]}/.ssh") && !params[:public_key].nil?
        end
      end
    end

    def kill_user_processes(name)
      Chef::Log.info("Killing all processes of user #{name}")
      execute "kill all processes of user #{name}" do
        command "pkill -u #{name}; true"
      end
    end

    def teardown_user(name)
      Chef::Log.info("tearing down user #{name}")
      kill_user_processes(name)

      execute "Force user #{name} deletion" do
        command "userdel -f #{name}"
      end
    end
  end
end

class Chef::Recipe
  include OpsWorks::User
end
class Chef::Resource::User
  include OpsWorks::User
end
