#
# Cookbook Name: artifakt_app_magento
# Definition: artifakt_magento_deploy
#

define :artifakt_magento_deploy  do
  release_path = node[:app_release_path]

  execute "Remove local.xml if not installed" do
    cwd "#{release_path}/"
    command "rm -f app/etc/local.xml"
    only_if { node[:app][:is_installed] == 'false' }
  end


  display_title do
    title "Running custom flush cache command of magento 1"
  end
  display_command do
      command "n98-magerun cache:flush"
  end
  run_command do
      command 'until [ "$(mysqladmin ping -h $ARTIFAKT_MYSQL_HOST -u $ARTIFAKT_MYSQL_USER -p$ARTIFAKT_MYSQL_PASSWORD)" == "mysqld is alive" ]; do sleep 10 && echo "Database is not ready yet, waiting ..."; done; echo "Database is ready, flushing Magento cache ..." && n98-magerun cache:flush'
      user node[:app_user]
      group node[:app_group]
      cwd "#{release_path}/"
      ignore_failure true
      environment node[:deploy][node[:app_name]][:environment_variables]
  end

end
