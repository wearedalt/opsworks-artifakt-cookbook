include_recipe 'mysql::service'

# Add directory in /var/log with good owner/group
directory '/var/log/mysql' do
  owner 'mysql'
  group 'mysql'
  mode '0755'
  recursive true
  action :create
end

template 'mysql configuration' do
  path value_for_platform(
    ['centos','redhat','fedora','amazon'] => {'default' => '/etc/my.cnf'},
    'default' => '/etc/mysql/my.cnf'
    )
  source 'my.cnf.erb'
  backup false
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, "service[mysql]"
end
