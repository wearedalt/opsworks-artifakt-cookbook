#
# Cookbook Name: artifakt_app_drupal
# Recipe: setup
#

bash "Install Drush" do
  user "root"
  code <<-EOH
      php -r "readfile('https://github.com/drush-ops/drush/releases/download/8.1.16/drush.phar');" > drush
      mv drush /usr/local/bin
      chmod +x /usr/local/bin/drush
  EOH
end

