#
# Cookbook Name: artifakt_app_magento
# Recipe: maintenance-off
#

node[:deploy].each do |app_name, deploy|
  bash "maintenance_on" do
    user "root"
    cwd "#{node[:deploy][:magento][:absolute_code_root]}/"
    code <<-EOH
      rm -rf maintenance.flag
      curl -X POST https://api.fastly.com/service/#{node['fastly_service_id']}/purge_all -H "Fastly-Key:#{node['fastly_api_key']}"  -H "Accept: application/json"
    EOH
  end
end
