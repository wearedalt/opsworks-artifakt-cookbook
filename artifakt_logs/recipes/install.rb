#
# Cookbook Name: artifakt_logs
# Recipe: install
#

display_title do
  title 'Setup artifakt logs'
end

package 'htop' do
  action :install
  retries 3
  retry_delay 5
end

directory "/etc/awslogs" do
  recursive true
end

logGroupName = node[:opsworks][:stack][:name].gsub(' ', '').gsub('-', '')

template "/etc/awslogs/cwlogs.cfg" do
  cookbook "artifakt_logs"
  source "cwlogs.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :instanceId => node[:opsworks][:instance][:id],
    :logGroupName => logGroupName,
    :filesToStream => node[node[:app][:type]][:files_to_stream]
  )
end

directory "/opt/aws/cloudwatch" do
  recursive true
end

remote_file "/opt/aws/cloudwatch/awslogs-agent-setup.py" do
  source "https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py"
  mode "0755"
end

execute "Install CloudWatch Logs agent" do
  command "/opt/aws/cloudwatch/awslogs-agent-setup.py -n -r #{node[:network][:region]} -c /etc/awslogs/cwlogs.cfg"
  not_if { system "pgrep -f aws-logs-agent-setup" }
end

# @FIXME: agent has to be runned for a few moments, before created the new group log name in CloudWatch,
# running the command just after the installation failed cause log group name does not exist yet

# retentionDaysForStackType = {
#   'standard' => 7,
#   'noscalable' => 30,
#   'scalable' => 90,
# }

# execute 'Set log retention' do
#   command "aws logs put-retention-policy --log-group-name #{logGroupName} --retention-in-days #{retentionDaysForStackType[node[:stack][:type]] || 90} --region #{node[:network][:region]}"
#   user 'root'
# end
