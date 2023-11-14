#
# Cookbook Name: artifakt
# Recipe: deploy
#
display_text do
    text 'COOKBOOK - Artifakt / recipes / deploy.rb'
end

if node[:app][:type]=='magento2' && node[:opsworks][:main_instance]
    if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]
        display_title do
            title "Stop Cron for Magento 2 before deploy"
        end
        execute 'Stop Cron service' do
            command "service crond stop"
        end
    end
end

# Fix bug Git Commit
bash "Create latestGitCommitHashPrefix file" do
code <<-EOH
    touch /tmp/latestGitCommitHashPrefix
    ls -lah /tmp
EOH
end

include_recipe 'deploy::php'

if node[:app][:type] == 'magento2'
    include_recipe 'artifakt_varnish::configure'
    include_recipe 'nginx::refresh-magento2-vhost'
end

if node[:app][:web_engine] == 'nginx'
    display_title do
        title "Restart Nginx + PHP-FPM"
    end
    service "nginx" do
        action :restart
    end
    if (node[:app][:language] != "74" && node[:app][:language][0] != '8')
        service "php-fpm" do
            action :restart
        end
    end
else
    display_title do
        title "Restart Apache2"
    end
    service "apache2" do
        action :restart
    end
end

if (node[:app][:language] == "74" || node[:app][:language][0] == '8')
    include_recipe 'php-fpm::restart-docker'
end

if node[:app][:type]=='magento2' && node[:opsworks][:main_instance]
    if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]
        display_title do
            title "Start Cron for Magento 2 after deploy"
        end
        execute 'Start Cron service' do
            command "service crond start"
        end
    end
end

if node[:quanta][:token]
    display_title do
        title 'Push deploy notification to Quanta'
    end
    include_recipe 'artifakt_quanta::deploy'
end

include_recipe 'artifakt_supervisor::restart'

display_title do
    title 'Deploy succeeded'
end