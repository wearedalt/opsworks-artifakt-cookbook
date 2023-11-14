#
# Cookbook Name: artifakt_quanta
# Recipe: deploy
#

execute "Push event to Quanta" do
  command "curl -X POST 'https://www.quanta-monitoring.com/api/artifaktio/events/push/#{node[:quanta][:token]}?content=deploy'"
end
