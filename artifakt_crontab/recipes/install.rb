#
# Cookbook Name: artifakt_crontab
# Recipe: install
#

display_title do
  title 'Installation of crontabs'
end

if node[:opsworks][:main_instance]
  if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]
    package 'crontabs' do
      package_name value_for_platform_family(
        'rhel' => 'crontabs',
        'debian' => 'cron'
      )
      retries 3
      retry_delay 5
      action :install
    end
  end
end