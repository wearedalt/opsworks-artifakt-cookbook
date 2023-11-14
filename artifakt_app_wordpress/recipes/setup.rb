#
# Cookbook Name: artifakt_app_wordpress
# Recipe: setup
#

bash "Install WPCLI" do
    user "root"
    code <<-EOH
      curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
      mv wp-cli.phar /usr/local/bin/wp
      chmod +x /usr/local/bin/wp
    EOH
end
