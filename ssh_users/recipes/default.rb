group 'opsworks'

display_title do
  title 'Creation of user who will deploy code'
end

# Create apache before everybody
user 'apache' do
  action :create
  comment "deploy user"
  non_unique true
  uid '48'
  gid 'opsworks'
  home "/var/www"
  supports :manage_home => true
  shell '/bin/bash'
end

display_title do
  title 'Creation/Update/Deletion of SSH users'
end

existing_ssh_users = load_existing_ssh_users
existing_ssh_users.each_key do |username|

  exist = false
  node[:ssh_users].each_key do |id|
    if node[:ssh_users][id].has_value?(username)
      exist = true
      break
    end
  end

  unless exist
    teardown_user(username)
  end

end

node[:ssh_users].each_key do |id|
  setup_user(node[:ssh_users][id])
  set_public_key(node[:ssh_users][id])
end

system_sudoer = case node[:platform]
                when 'debian'
                  'admin'
                when 'ubuntu'
                  'ubuntu'
                when 'redhat','centos','fedora','amazon'
                   'ec2-user'
                end

template '/etc/sudoers' do
  backup false
  source 'sudoers.erb'
  owner 'root'
  group 'root'
  mode 0440
  variables :sudoers => node[:sudoers], :system_sudoer => system_sudoer
  only_if { infrastructure_class? 'ec2' }
end

template '/etc/sudoers.d/opsworks' do
  backup false
  source 'sudoers.d.erb'
  owner 'root'
  group 'root'
  mode 0440
  variables :sudoers => node[:sudoers], :system_sudoer => system_sudoer
  not_if { infrastructure_class? 'ec2' }
end
