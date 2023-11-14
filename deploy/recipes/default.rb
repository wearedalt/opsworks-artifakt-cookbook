display_text do
  text 'COOKBOOK - deploy / recipes / default.rb'
end

include_recipe 'artifakt_certificates'
include_recipe 'artifakt_runtime_config'

include_recipe 'dependencies'

node[:deploy].each do |application, deploy|

  opsworks_deploy_user do
    deploy_data deploy
  end

end
