#
# Cookbook Name: artifakt_elasticsearch
# Recipe: install
#

if node[:stack][:type] != 'standard' 
  if (node[:app][:aws_es])
    display_text do
      text "Elasticsearch - SUCCESS - Info aws_es found in app"
    end
    if (node[:app][:aws_es][:endpoint])
      display_text do
        text "Elasticsearch - SUCCESS - Endpoint found."
      end
      display_title do
        title 'Set AWS Elasticsearch proxy'
      end
      bash "Set AWS Elasticsearch proxy" do
        user "root"
        code <<-EOH
        echo "Analyzing web engine..."
        echo "Web engine: #{node[:app][:web_engine]}"
        if [[ "#{node[:app][:web_engine]}" == "nginx" ]]; then
          echo "Creating vhost for Nginx"
          if [ ! -f "/etc/nginx/sites-enabled/esAws" ]; then
            echo 'Create esAws vhost on port 8090'
            echo "server {" > /etc/nginx/sites-available/esAws
            echo "  listen 8090;" >> /etc/nginx/sites-available/esAws
            echo "  location / {" >> /etc/nginx/sites-available/esAws
            echo "      proxy_pass #{node[:app][:aws_es][:endpoint]};" >> /etc/nginx/sites-available/esAws
            echo "  }" >> /etc/nginx/sites-available/esAws
            echo "}" >> /etc/nginx/sites-available/esAws
            ln -s /etc/nginx/sites-available/esAws /etc/nginx/sites-enabled/esAws
            service nginx reload
            echo "The vhost has been created, please use these information to connect to your ES with CLI: --search-engine=elasticsearch7 --elasticsearch-host=localhost --elasticsearch-username=<username> --elasticsearch-port=8090 --elasticsearch-password=<password> --elasticsearch-enable-auth=1"
          else
            echo "The esAws vhost already exists. You can use these information to connect to your ES with CLI: --search-engine=elasticsearch7 --elasticsearch-host=localhost --elasticsearch-username=<username> --elasticsearch-port=8090 --elasticsearch-password=<password> --elasticsearch-enable-auth=1"
          fi
        elif [[ "#{node[:app][:web_engine]}" == "apache" ]]; then
          if [ ! -f "/etc/httpd/sites-enabled/esAws.conf" ]; then
              echo "Creating vhost for apache"
              echo "<VirtualHost *:8090>" > /etc/httpd/sites-available/esAws.conf
              echo "SSLProxyEngine on" >> /etc/httpd/sites-available/esAws.conf
              echo "SSLProxyVerify none" >> /etc/httpd/sites-available/esAws.conf
              echo "SSLProxyCheckPeerCN off" >> /etc/httpd/sites-available/esAws.conf
              echo "SSLProxyCheckPeerName off" >> /etc/httpd/sites-available/esAws.conf
              echo "SSLProxyCheckPeerExpire off" >> /etc/httpd/sites-available/esAws.conf
              echo "ProxyPass / #{node[:app][:aws_es][:endpoint]}" >> /etc/httpd/sites-available/esAws.conf
              echo "ProxyPassReverse / #{node[:app][:aws_es][:endpoint]}" >> /etc/httpd/sites-available/esAws.conf
              echo "</VirtualHost>" >> /etc/httpd/sites-available/esAws.conf
              a2ensite esAws.conf
              echo "The vhost has been created, please use these information to connect to your ES with CLI: --search-engine=elasticsearch7 --elasticsearch-host=localhost --elasticsearch-port=8090 --elasticsearch-enable-auth=0"
          else
              echo "The esAws vhost already exists. You can use these information to connect to your ES with CLI: --search-engine=elasticsearch7 --elasticsearch-host=localhost --elasticsearch-port=8090 --elasticsearch-enable-auth=0"
          fi
          if ! grep -q 8090 /etc/httpd/ports.conf; then
            echo "Listen 8090" >> /etc/httpd/ports.conf
          fi
          service httpd reload
        fi

        EOH
      end
    else
      display_text do
        text 'Please indicate all information for aws_es: endpoint (https://xxxx), username and password.'
      end
    end
  end 
else
  if node[:es][:installed] == "true"
    display_title do
      title 'Install Elasticsearch container'
    end
    bash "install_es" do
      user "root"
      code <<-EOH
      mkdir -p /mnt/shared/elasticsearch
      chmod -R 777 /mnt/shared/elasticsearch
      sysctl -w vm.max_map_count=262144
      if [ "$(docker ps -q -f name=elasticsearch -a)" ]; then docker stop elasticsearch; fi
      if [ "$(docker ps -q -f name=elasticsearch -a)" ]; then docker rm elasticsearch; fi
      EOH
    end

    display_title do
      title "Add directory #{node['es']['docker_dir']}"
    end
    directory "#{node['es']['docker_dir']}" do
      action :create
      mode 0755
      owner "root"
      group "root"
    end

    display_title do
      title 'Add docker-compose.yml'
    end
    template "#{node['es']['docker_dir']}/docker-compose.yml" do
      source "docker-compose.yml"
      mode 0755
      group "root"
      owner "root"
    end

    display_title do
      title 'Add Dockerfile'
    end
    template "#{node['es']['docker_dir']}/Dockerfile" do
      source "Dockerfile.erb"
      mode 0755
      group "root"
      owner "root"
    end

    bash "check_es_status_and_cleanup_if_exited" do
      user "root"
      cwd "#{node['es']['docker_dir']}/"
      code <<-EOH
        if [ "$(docker ps -aq -f name=es -f status=exited)" ]; then
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
      cwd "#{node['es']['docker_dir']}/"
    end

    display_command do
      command "docker system prune -f"
    end
    run_command do
      command 'docker system prune -f'
      user "root"
      group "root"
      cwd "#{node['es']['docker_dir']}/"
    end
  end 
end