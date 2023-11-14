#
# Cookbook Name: artifakt_composer
# Recipe: install
#

display_title do
  title 'Installation of composer: '+node[:composer][:version]
end
if node[:composer] && node[:composer][:version]
  bash "install_composer" do
      user "root"
      code <<-EOH
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php -d memory_limit=-1 composer-setup.php --version=#{node[:composer][:version]}
        php -r "unlink('composer-setup.php');"
        mv composer.phar /usr/local/bin/composer
      EOH
  end
else
  bash "install_composer" do
    user "root"
    code <<-EOH
      php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
      php -d memory_limit=-1 composer-setup.php
      php -r "unlink('composer-setup.php');"
      mv composer.phar /usr/local/bin/composer
    EOH
  end
end

bash "add apache composer cache" do
    user "root"
    code <<-EOH
      mkdir -p /var/www/.composer
      chown -R apache:opsworks /var/www/.composer
      chmod -R 777 /var/www/.composer
    EOH
end

display_title do
  title 'Installation of supervisor'
end

package 'supervisor' do
  retries 3
  retry_delay 5
  action :install
end

bash "install_supervisor" do
  user "root"
  code <<-EOH
    pip install supervisor
  EOH
end
