#
# Cookbook Name:: apache2
# Recipe:: php5
#
# Copyright 2008, OpsCode, Inc.
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
if (node[:app][:language] != "74" && node[:app][:language][0] != '8')
  module_php = 'php5'

  if node[:app][:language][0] == '7'
    module_php = 'php7'
  end

  display_title do
    title "Installation of #{module_php}"
  end

  case node[:platform_family]
  when 'debian'
    # @TODO: if we are in debian no php7 ??
    package 'libapache2-mod-php5' do
      action :install
      retries 3
      retry_delay 5
    end
  when 'rhel'

    # @TODO: put this in a setup
    # if(node[:app][:language][0] == '7')
    #   execute 'remove php5 lib' do
    #     user 'root'
    #     command "a2dismod -f php5"
    #   end
    #   package "php" do
    #     action :remove
    #   end
    #   package "php-cli" do
    #     action :remove
    #   end
    #   execute 'remove php5 packages' do
    #     user 'root'
    #     command "yum remove php5* -y"
    #   end
    # end

    package module_php do
      action :install
      retries 3
      retry_delay 5
      notifies :run, "execute[generate-module-list]", :immediately
      not_if 'which php'
    end

    # remove stock config
    file File.join(node[:apache][:dir], 'conf.d', 'php.conf') do
      action :delete
    end

    if module_php == 'php5'
      # replace with debian config
      template File.join(node[:apache][:dir], 'mods-available', 'php5.conf') do
        source 'mods/php5.conf.erb'
        notifies :restart, "service[apache2]"
      end
    else
      template File.join(node[:apache][:dir], 'mods-available', 'php7.conf') do
        source 'mods/php7.conf.erb'
        notifies :restart, "service[apache2]"
      end
    end
  end

  if(node[:app][:language] == '54')
    apache_module module_php do
      if platform_family?('rhel')
        filename "libphp5.so"
      end
    end
  else
    apache_module module_php do
      if platform_family?('rhel')
        filename "libphp-#{node[:app][:language_long]}.so"
      end
    end
  end
end

