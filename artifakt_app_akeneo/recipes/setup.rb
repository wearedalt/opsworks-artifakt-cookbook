#
# Cookbook Name: artifakt_app_akeneo
# Recipe: setup
#

bash "install nodejs" do
    user "root"
    code <<-EOH
    curl -sL "https://rpm.nodesource.com/setup_#{node[:akeneo][:version_node]}.x" | bash -
    yum -y install nodejs
    npm install yarn -g
    mkdir -p /var/www/.cache/yarn
    chown -R apache:opsworks /var/www/.cache/yarn
    chmod -R 775 /var/www/.cache/yarn
    mkdir -p /var/www/.yarn
    chown -R apache:opsworks /var/www/.yarn
    chmod -R 775 /var/www/.yarn
    EOH
end

bash "install imageMagick" do
    user "root"
    code <<-EOH
    yum -y install php7-pear ImageMagick ImageMagick-devel ImageMagick-perl
    printf "\n" | pecl7 install imagick
    echo extension=imagick.so >> /etc/php.ini
    service httpd restart
    EOH
end

template "/etc/yum.repos.d/elasticsearch.repo" do
    source "elasticsearch.repo.erb"
    cookbook "artifakt_app_akeneo"
    owner 'root'
end

bash "install elasticsearch" do
    user "root"
    code <<-EOH
    yum -y remove java
    yum -y install java-1.8.0-openjdk-devel
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    yum -y install elasticsearch
    chmod g+w /etc/elasticsearch
    sed -i -e 's/#ES_JAVA_OPTS=/ES_JAVA_OPTS="-Xms512m -Xmx512m"/g' /etc/sysconfig/elasticsearch
    service elasticsearch start
    EOH
end

package 'aspell' do
    retries 3
    retry_delay 5
    action :install
end

bash "install Ghostscript" do
    user "root"
    code <<-EOH
    wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs952/ghostscript-9.52.tar.gz
    tar xzf ghostscript-9.52.tar.gz
    cd ghostscript-9.52
    ./configure
    make
    sudo make install
    EOH
end
