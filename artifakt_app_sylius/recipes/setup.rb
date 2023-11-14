#
# Cookbook Name: artifakt_app_sylius
# Recipe: setup
#

bash "Node.js installation" do
    user "root"
    code <<-EOH
    curl -sL "https://rpm.nodesource.com/setup_#{node[:sylius][:version_node]}.x" | bash -
    yum -y install nodejs
    npm install yarn -g
    mkdir -p /var/www/.cache/yarn
    chown -R apache:opsworks /var/www/.cache/yarn
    chmod -R 775 /var/www/.cache/yarn
    mkdir -p /var/www/.yarn
    chown -R apache:opsworks /var/www/.yarn
    chmod -R 775 /var/www/.yarn
    test -f /var/www/.babel.json || touch /var/www/.babel.json
    chown apache:opsworks /var/www/.babel.json
    chmod 664 /var/www/.babel.json
    EOH
end
