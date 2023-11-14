#
# Cookbook Name: artifakt_redis
# Recipe: install
#

if node[:stack][:type] == 'standard'
  if node[:redis][:installed] == "true"
      display_title do
          title 'Starting Redis Docker container'
      end
      bash "remove_existing_containers_redis" do
      user "root"
      code <<-EOH
          if [ "$(docker ps -q -f name=redis -a)" ]; then docker stop redis; fi
          if [ "$(docker ps -q -f name=redis -a)" ]; then docker rm redis; fi
      EOH
      end

      display_title do
      title "Add directory #{node['redis']['docker_dir']}"
      end
      directory "#{node['redis']['docker_dir']}" do
          action :create
          mode 0755
          owner "root"
          group "root"
      end

      display_title do
      title 'Add docker-compose.yml'
      end
      template "#{node['redis']['docker_dir']}/docker-compose.yml" do
          source "docker-compose.yml.erb"
          mode 0755
          group "root"
          owner "root"
      end

      bash "check_redis_status_and_cleanup_if_exited" do
        user "root"
        cwd "#{node['redis']['docker_dir']}/"
        code <<-EOH
          if [ "$(docker ps -aq -f name=redis -f status=exited)" ]; then
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
          cwd "#{node['redis']['docker_dir']}/"
      end

      display_command do
          command "docker system prune -f"
      end
      run_command do
          command 'docker system prune -f'
          user "root"
          group "root"
          cwd "#{node['redis']['docker_dir']}/"
      end
  end
end

# Legacy
if  node[:ec][:installed] == "true"

    display_title do
        title 'Installation of redis'
    end

    bash "install_es_17" do
        user "root"
        code <<-EOH
        yum install epel-release
        yum update
        yum install -y redis
        /etc/init.d/redis start
        chkconfig --add redis
        EOH
    end
end
