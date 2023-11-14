#
# Cookbook Name: artifakt_app_magento
# Recipe: setup
#

bash "Install N98" do
    user "root"
    code <<-EOH
		  wget https://files.magerun.net/n98-magerun.phar
      mv n98-magerun.phar /usr/local/bin/n98-magerun
      chmod +x /usr/local/bin/n98-magerun
    EOH
end

execute 'Set env' do
    command 'export MAGE_IS_DEVELOPER_MODE=0'
    only_if { node[:stack][:mode] == 'prod' }
end
