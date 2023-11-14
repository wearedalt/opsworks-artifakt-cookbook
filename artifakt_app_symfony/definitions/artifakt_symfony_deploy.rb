#
# Cookbook Name: artifakt_app_symfony
# Definition: artifakt_symfony_deploy
#

define :artifakt_symfony_deploy  do
  release_path = node[:app_release_path]
  env = "--env=#{node[:stack][:mode]}"

  display_command do
    command "php bin/console assets:install #{env}"
  end
  run_command do
    command "php bin/console assets:install #{env} --ansi"
    user node[:app_user]
    group node[:app_group]
    environment node[:deploy][node[:app_name]][:environment_variables]
    cwd "#{release_path}/"
  end

  if node[:app][:is_installed] == 'true'
    display_command do
      command "php bin/console do:sc:up --force"
    end
    run_command do
      command "php bin/console do:sc:up --force --ansi"
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    display_command do
      command "php bin/console cache:warmup #{env}"
    end
    run_command do
      command "php bin/console cache:warmup #{env} --ansi"
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end
  end
end
