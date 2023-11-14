#
# Author::  Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: php-fpm
# Recipe:: package
#
# Copyright 2011-2017, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

display_title do
  title 'Remove old php-fpm'
end
bash "Remove old php-fpm" do
  code <<-EOH
    yum remove -y php-fpm php-cli php-common
  EOH
end

display_title do
  title 'Installation of mysql commands'
end
package 'mysql' do
  package_name value_for_platform_family(
     'rhel' => 'mysql',
     'debian' => 'mysql-client'
  )
  retries 3
  retry_delay 5
end

php_fpm_package_name = if node['php-fpm']['package_name'].nil?
                         if platform_family?('rhel', 'fedora')
                           'php-fpm'
                         elsif platform?('ubuntu') && node['platform_version'].to_f >= 16.04
                           'php7.0-fpm'
                         else
                           'php5-fpm'
                         end
                       else
                         node['php-fpm']['package_name']
                       end



display_title do
  title "Installation of #{php_fpm_package_name}"
end

package php_fpm_package_name do
  action node['php-fpm']['installation_action']
  version node['php-fpm']['version'] if node['php-fpm']['version']
end

node[:php][:packages].each do |pkg|
  package pkg do
    action :install
    ignore_failure(pkg.to_s.match(/^php-pear-/) ? true : false) # some pear packages come from EPEL which is not always available
    retries 3
    retry_delay 5
  end
end

if node[:app][:language] == "72" || node[:app][:language] == "73"
  bash "EPEL/Remi repository configuration packages" do
    code <<-EOH
      mv -f /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6.bkp
      yum reinstall -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
      mv -f /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6.bkp /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
      yum reinstall -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm || yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    EOH
  end

  bash "PHP #{node[:app][:language_long]} - Fix for Sodium" do
    code <<-EOH
      yum install -y php#{node[:app][:language]}-php-sodium --enablerepo remi-php#{node[:app][:language]}
      cp -n /opt/remi/php#{node[:app][:language]}/root/usr/lib64/php/modules/sodium.so /usr/lib64/php/#{node[:app][:language_long]}/modules/
      bash -c "echo extension=sodium.so > /etc/php-#{node[:app][:language_long]}.d/20-sodium.ini"
    EOH
  end
end

if node[:app][:language] == "73"
  bash "PHP #{node[:app][:language_long]} - Fix for APCu and Memcache" do
    code <<-EOH
      yum install -y php#{node[:app][:language]}-php-pecl-apcu php#{node[:app][:language]}-php-pecl-memcache --enablerepo remi-php#{node[:app][:language]}
      cp -n /opt/remi/php#{node[:app][:language]}/root/usr/lib64/php/modules/apcu.so /usr/lib64/php/#{node[:app][:language_long]}/modules/
      cp -n /opt/remi/php#{node[:app][:language]}/root/usr/lib64/php/modules/memcache.so /usr/lib64/php/#{node[:app][:language_long]}/modules/
      bash -c "echo extension=apcu.so > /etc/php-#{node[:app][:language_long]}.d/10-apcu.ini"
      bash -c "echo extension=memcache.so > /etc/php-#{node[:app][:language_long]}.d/10-memcache.ini"

      rm -rf /usr/lib64/php/7.3/modules/curl.so
      cp -n /opt/remi/php73/root/usr/lib64/php/modules/curl.so /usr/lib64/php/7.3/modules/
    EOH
  end
end

display_title do
  title "Service name for php-fpm: "+node['php-fpm']['service_name']
end

php_fpm_service_name = if node['php-fpm']['service_name'].nil?
                         php_fpm_package_name
                       else
                         node['php-fpm']['service_name']
                       end

service_provider = nil
# this is actually already done in chef, but is kept here for older chef releases
if platform?('ubuntu') && node['platform_version'].to_f.between?(13.10, 14.10)
  service_provider = ::Chef::Provider::Service::Upstart
end

directory node['php-fpm']['log_dir']

template 'etc/php-fpm.d/www.conf' do
  source 'www.conf.erb'
  mode 00644
  owner 'root'
  group 'root'
end

service 'php-fpm' do
  provider service_provider if service_provider
  service_name php_fpm_service_name
  supports start: true, stop: true, restart: true, reload: true
  action [:enable, :start]
  only_if { !File.exists?("/var/run/php-fpm-www.sock")}
end
