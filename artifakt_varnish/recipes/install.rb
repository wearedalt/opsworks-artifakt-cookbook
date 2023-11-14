#
# Cookbook Name: artifakt_varnish
# Recipe: install
#

if node[:app][:varnish][:installed] == 'true'
  display_title do
    title "Varnish installation"
  end

  display_title do
    title "Add directory #{node['varnish']['docker_dir']}"
  end
  directory "#{node['varnish']['docker_dir']}" do
    action :create
    owner "root"
    group "root"
    mode 0755
  end

  display_title do
    title "Add directory #{node['varnish']['conf_dir']}"
  end
  directory "#{node['varnish']['conf_dir']}" do
    action :create
    owner "root"
    group "root"
    mode 0755
  end

  display_title do
    title 'Add docker-compose.yml'
  end
  template "#{node['varnish']['docker_dir']}/docker-compose.yml" do
    source "docker-compose.yml.erb"
    mode 0755
    group "root"
    owner "root"
  end

  display_title do
    title 'Add default.vcl'
  end
  template "#{node['varnish']['conf_dir']}/default.vcl" do
    source "default_v#{node['varnish']['version']}.vcl"
    mode 0755
    group "root"
    owner "root"
  end

  display_title do
    title 'Add varnishRefreshConfig.ksh'
  end
  template "#{node['varnish']['docker_dir']}/varnishRefreshConfig.ksh" do
    source "varnishRefreshConfig.ksh.erb"
    mode 0755
    group "root"
    owner "root"
  end

  display_title do
      title 'Add varnishRefreshMagentoConfig.ksh'
    end
    template "#{node['varnish']['docker_dir']}/varnishRefreshMagentoConfig.ksh" do
      source "varnishRefreshMagentoConfig.ksh.erb"
      mode 0755
      group "root"
      owner "root"
    end

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

  bash "update_and_reload_nginx_config" do
    code <<-EOH
      sed -i -e "s/listen 80;/listen 8080;/g" /etc/nginx/sites-available/magento
      service nginx reload
    EOH
  end

  bash "check_varnish_status_and_cleanup_if_exited" do
    user "root"
    cwd "#{node['varnish']['docker_dir']}/"
    code <<-EOH
      if [ "$(docker ps -aq -f name=varnish -f status=exited)" ]; then
          docker-compose down
      fi
    EOH
  end

  display_command do
    command "docker-compose up -d --build --remove-orphans"
  end
  run_command do
    command 'docker-compose up -d --build --remove-orphans'
    user "root"
    group "root"
    cwd "#{node['varnish']['docker_dir']}/"
  end

  display_command do
    command "docker system prune -f"
  end
  run_command do
    command 'docker system prune -f'
    user "root"
    group "root"
    cwd "#{node['varnish']['docker_dir']}/"
  end

else
  display_title do
    title "Checking if varnish is installed - If yes, uninstall"
  end

  bash "remove_varnish" do
    code <<-EOH

      echo "Checking if a container named Varnish is running ..."
      if [ "$(docker ps -q -f name=varnish -a)" ]; then
        echo "**********************************************"
        echo "VARNISH UNINSTALL - IN PROGRESS"
        echo "**********************************************"

        echo "NGINX - Rollback configuration to port 80 - IN PROGRESS"
        sed -i -e "s/listen 8080;/listen 80;/g" /etc/nginx/sites-available/magento
        echo "NGINX - Rollback configuration to port 80 - DONE"

        echo "VARNISH - Stop container, remove and reload nginx configuration in one shot - IN PROGRESS"
        cd #{node['varnish']['docker_dir']}
        docker-compose stop && docker-compose rm -f && service nginx reload
        if [ ! "$(docker ps -q -f name=varnish -a)" ]; then
          echo "VARNISH - No container running, deletion successfull (images cleaned with docker image prune -f command)"
          docker image prune -f
        fi
        echo "VARNISH - Stop container, remove and reload nginx configuration in one shot - DONE"

        echo "**********************************************"
        echo "VARNISH UNINSTALL - DONE"
        echo "**********************************************"
      else
        echo "INFO - No Varnish container found."
      fi
    EOH
  end

end
