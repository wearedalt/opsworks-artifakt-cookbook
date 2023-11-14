#
# Cookbook Name: artifakt_crontab
# Recipe: setup
#

template "/var/www/crontabfile" do
    source "empty_crontab.erb"
    mode 0770
    owner 'apache'
end

if node[:opsworks][:main_instance]
    if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]
        template "/var/www/crontabfile" do
            source "crontab.erb"
            mode 0770
            owner 'apache'
            variables(
                :crontab => (node[:stack][:crontab] rescue nil),
            )
        end
    end
end

bash "Setup crontab" do
    user "apache"
    cwd "/var/www"
    code <<-EOH
    crontab < crontabfile
    EOH
end