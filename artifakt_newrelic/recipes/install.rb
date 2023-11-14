if node[:app][:newrelic][:installed] == 'true' && node[:app][:language] != "74" && node[:app][:language][0] != '8'

    display_title do
        title "Setup New Relic #{node[:app][:newrelic][:agent_version_non_docker]} - #{node[:app][:newrelic][:app_name]}"
    end
    bash 'install new relic' do
        code <<-EOH
          wget https://download.newrelic.com/pub/newrelic/el5/x86_64/newrelic-php5-common-#{node[:app][:newrelic][:agent_version_non_docker]}.noarch.rpm
          wget https://download.newrelic.com/pub/newrelic/el5/x86_64/newrelic-daemon-#{node[:app][:newrelic][:agent_version_non_docker]}.x86_64.rpm
          wget https://download.newrelic.com/pub/newrelic/el5/x86_64/newrelic-php5-#{node[:app][:newrelic][:agent_version_non_docker]}.x86_64.rpm
          rpm -i newrelic-php5-common-#{node[:app][:newrelic][:agent_version_non_docker]}.noarch.rpm newrelic-daemon-#{node[:app][:newrelic][:agent_version_non_docker]}.x86_64.rpm newrelic-php5-#{node[:app][:newrelic][:agent_version_non_docker]}.x86_64.rpm
          export NR_INSTALL_SILENT=true
          export NR_INSTALL_KEY="#{node[:app][:newrelic][:key]}"
          export NR_APPNAME="#{node[:app][:newrelic][:app_name]}"
          sed -i -e 's/newrelic.appname =.*/newrelic.appname = "#{node[:app][:newrelic][:app_name]}"/' $(php -i|grep "/newrelic.ini"|tr ',' ' ')
          newrelic-install install
        EOH
        action :run
    end
    if node[:app][:web_engine] =='nginx'
        service 'nginx' do
            action :restart
        end
        service 'php-fpm' do
            action :restart
        end
    else
        service 'httpd' do
            action :restart
        end
    end
end
