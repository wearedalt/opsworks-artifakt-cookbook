#
# Cookbook Name: artifakt
# Definition:run_command
#

# https://discourse.chef.io/t/mixliv-command-run-command-executed-at-compile-time/4990/3

define :run_command, :command => nil, :user => nil, :group => nil, :cwd => nil, :environment => {} do

  ruby_block "run_command" do
    block do
      puts OpsWorks::ShellOut.shellout(params[:command], :user => params[:user], :group => params[:group], :cwd => params[:cwd], :environment => params[:environment])
    end
  end

end
