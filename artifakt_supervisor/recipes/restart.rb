#
# Cookbook Name: artifakt_supervisor
# Recipe: restart
#

if node[:supervisor][:installed] == "true"
    if node[:opsworks][:main_instance]
        if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]
            display_title do
             title 'Restart supervisor'
            end
            service "supervisord" do
                action :restart
            end
        end
    end
end