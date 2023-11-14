#
# Cookbook Name: artifakt
# Attributes: default
#

default[:app][:maintenance] = 'false'

default[:ec][:installed] = false
default[:elc][:prefix] = 'magento_'
default[:php][:session_path] = '/tmp'
default[:command][:type] = 'none'
default[:app][:varnish][:installed] = "false"
default[:app][:boprefix]="admin"
default[:app][:secret]="zQCvhDu2V9eTDD3z4PcA2ex72yTVLZnG"
default[:app][:fpc]=true
default[:app][:shared_files] = []
