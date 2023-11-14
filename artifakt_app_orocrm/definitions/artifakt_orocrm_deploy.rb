#
# Cookbook Name: artifakt_app_orocrm
# Definition: artifakt_orocrm_deploy
#

define :artifakt_orocrm_deploy  do
  release_path = node[:app_release_path]

  display_command do
    command "composer install --prefer-dist #{node[:composer][:extra_params]}"
  end
  run_command do
    command "composer install --prefer-dist #{node[:composer][:extra_params]}"
    user node[:app_user]
    group node[:app_group]
    cwd "#{release_path}/"
  end

end
