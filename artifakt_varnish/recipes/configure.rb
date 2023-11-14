#
# Cookbook Name: artifakt_varnish
# Recipe: configure
#

if node[:app][:varnish][:installed] == 'true'
    display_command do
        command "./varnishRefreshConfig.ksh"
    end
    run_command do
        command './varnishRefreshConfig.ksh'
        user "root"
        group "root"
        cwd "#{node['varnish']['docker_dir']}/"
        environment node[:deploy][node[:app_name]][:environment_variables]
    end
    display_command do
        command "./varnishRefreshMagentoConfig.ksh"
    end
    run_command do
        command './varnishRefreshMagentoConfig.ksh'
        user "root"
        group "root"
        cwd "#{node['varnish']['docker_dir']}/"
        environment node[:deploy][node[:app_name]][:environment_variables]
    end
end
