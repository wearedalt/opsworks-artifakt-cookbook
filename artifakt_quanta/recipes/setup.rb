#
# Cookbook Name: artifakt_quanta
# Recipe: setup
#

template "/etc/yum.repos.d/quanta.repo" do
    source "quanta.repo.erb"
end

execute 'Add Quanta key' do
    command 'curl https://rpm.quanta.io/quanta-repo-key.gpg -o /tmp/quanta.key && rpm --import /tmp/quanta.key && rm /tmp/quanta.key'
end

execute 'Update packages' do
    command 'yum makecache'
end

package 'quanta-agent' do
    retries 3
    retry_delay 5
    action :install
end

template "/etc/quanta/agent.yml" do
    source "agent.yml.erb"
    variables(
        :hostname => (node[:opsworks][:instance][:hostname] rescue nil),
        :token => (node[:quanta][:token] rescue nil),
    )
end

#package "php#{node[:app][:language]}-quanta-mon" do
#    retries 3
#    retry_delay 5
#    action :install
#end

#execute 'Make symlink to quanta php module' do
#    command "ln -sf /usr/lib64/php/modules/quanta_mon.so /usr/lib64/php/#{node[:app][:language_long]}/modules/quanta_mon.so"
#end

execute 'Start agent' do
    command 'service quanta-agent start'
end

execute 'Start agent startup' do
    command 'chkconfig quanta-agent on'
end