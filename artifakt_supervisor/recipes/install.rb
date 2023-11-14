#
# Cookbook Name: artifakt_supervisor
# Recipe: install
#
display_title do
    title "Cookbook artifakt_supervisor called"
end
if node[:supervisor][:installed] == "true"
    if node[:opsworks][:main_instance]
        display_title do
         title "Checking main instance: #{node[:opsworks][:main_instance]}"
        end
        if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]
            display_title do
             title 'Install supervisor'
            end
            bash "install_supervisor" do
                user "root"
                code <<-EOH
                    yum install -y supervisor
                    pip install supervisor
                EOH
            end
            if node[:app][:type] == 'orocommerce' || node[:app][:type] == 'akeneo'
                display_title do
                    title "Apply #{node[:app][:type]} supervisor configuration"
                end
                template "/etc/supervisord.conf" do
                    source "#{node[:app][:type]}-supervisord.conf"
                    mode 0644
                    owner 'root'
                end
            end
            display_title do
                title 'Restart supervisor service'
            end
            bash "start_supervisor" do
                user "root"
                code <<-EOH
                    service supervisord start
                EOH
            end
        end
    end
end