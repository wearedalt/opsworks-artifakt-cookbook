remote_file '/tmp/amazon-cloudwatch-agent.rpm' do
    source 'https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

package '/tmp/amazon-cloudwatch-agent.rpm' do
    action :install
end


template "/opt/aws/amazon-cloudwatch-agent/etc/common-config.toml" do
    source "config.erb"
    owner 'root'
    group 'root'
end


template "/opt/aws/amazon-cloudwatch-agent/bin/config.json" do
    source "config_metrics.erb"
    owner 'root'
    group 'root'
end

run_command do
    command "mkdir -p /usr/share/collectd/ && touch /usr/share/collectd/types.db"
    user "root"
    group "root"
end

run_command do 
    command "/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json"
    user "root"
    group "root"
end

bash 'start agent' do
    code <<-EOH
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -m ec2
    EOH
    action :run
end
