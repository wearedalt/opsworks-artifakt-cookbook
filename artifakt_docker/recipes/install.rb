#
# Cookbook Name: artifakt_docker
# Recipe: install
#

display_title do
    title 'Installation of Docker'
  end

  bash 'Configure Docker' do
      code <<-EOH
      yum update
      yum install docker -y
      usermod -a -G docker ec2-user
      service docker start
      chkconfig docker off
      EOH
  end

  display_title do
    title 'Installation of Docker Compose 1.29.2'
  end

  bash 'name' do
      code <<-EOH
      curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
      chmod +x /usr/local/bin/docker-compose
      mv /usr/local/bin/docker-compose /usr/bin/docker-compose
      EOH
  end
