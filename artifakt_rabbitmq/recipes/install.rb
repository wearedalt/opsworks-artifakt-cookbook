#
# Cookbook Name: artifakt_rabbitmq
# Recipe: install
#

display_title do
    title 'Checking if RabbitMQ is required'
end
if node[:rabbitmq][:installed] == "true"
    display_title do
        title 'Install RabbitMQ container'
    end
    bash "remove_existing_containers_rabbitmq" do
    user "root"
    code <<-EOH
        if [ "$(docker ps -q -f name=rabbitmq -a)" ]; then docker stop rabbitmq; fi
        if [ "$(docker ps -q -f name=rabbitmq -a)" ]; then docker rm rabbitmq; fi
    EOH
    end

    display_title do
    title "Add directory #{node['rabbitmq']['docker_dir']}"
    end
    directory "#{node['rabbitmq']['docker_dir']}" do
        action :create
        mode 0755
        owner "root"
        group "root"
    end

    display_title do
    title 'Add docker-compose.yml'
    end
    template "#{node['rabbitmq']['docker_dir']}/docker-compose.yml" do
        source "docker-compose.yml.erb"
        mode 0755
        group "root"
        owner "root"
    end

    bash "check_rabbitmq_status_and_cleanup_if_exited" do
      user "root"
      cwd "#{node['rabbitmq']['docker_dir']}/"
      code <<-EOH
        if [ "$(docker ps -aq -f name=rabbitmq -f status=exited)" ]; then
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
        cwd "#{node['rabbitmq']['docker_dir']}/"
    end

    display_command do
        command "docker system prune -f"
    end
    run_command do
        command 'docker system prune -f'
        user "root"
        group "root"
        cwd "#{node['rabbitmq']['docker_dir']}/"
    end
else
    display_title do
        title 'RabbitMQ not activated'
    end
end 