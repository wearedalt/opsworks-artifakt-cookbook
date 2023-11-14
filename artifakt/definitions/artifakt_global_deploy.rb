#
# Cookbook Name: artifakt
# Definition: artifakt_global_deploy
#

define :artifakt_global_deploy  do
  display_text do
    text 'COOKBOOK - Artifakt / definitions / artifakt_global_deploy.rb'
  end

  release_path = node[:app_release_path]
  short_release_path = node[:short_release_path]
  app_type = node[:app][:type]
  app_name = node[:app_name]
  custom_deploy = "artifakt_#{node[:app][:type]}_deploy"
  regional_opsworks = [
  'eu-west-2',
  'eu-west-3',
  'us-east-2',
  'ap-northeast-2',
  'ap-south-1'
  ]
  region = 'us-east-1'
  if regional_opsworks.include? node[:opsworks][:instance][:region]
    region = node[:opsworks][:instance][:region]
  end

  code_root_done="todo"
  if node[:deploy]
    if node[:deploy][node[:app][:type]]    
      if node[:deploy][node[:app][:type]][:code_root]
        display_title do
          title "Adding directory as safe.directory for git:#{node[:short_release_path]} "
        end

        run_command do
          command "rm -rf ~/.gitconfig && \
            newReleasePath=$(echo \"#{release_path}\" | sed 's:/*$::') && \
            echo \"Edited path: $newReleasePath\" && \
            git config --global --add safe.directory $newReleasePath && \
            chown apache:opsworks /var/www/.gitconfig && \
            chmod 755 /var/www/.gitconfig && \
            ls -lah /var/www"
          user "root"
          group "root"
          cwd "#{release_path}/"
        end
      
        code_root_done="done"
      end
    end
  end

  if code_root_done == "todo"
    display_title do
      title "Adding directory as safe.directory for git: #{release_path}"
    end
    run_command do
      command "rm -rf ~/.gitconfig && git config --global --add safe.directory #{node[:short_release_path]} && \
        chown apache:opsworks /var/www/.gitconfig && \
        chmod 755 /var/www/.gitconfig && \
        ls -lah /var/www"
      user "root"
      group "root"
      cwd "#{node[:short_release_path]}/"
    end

  end
  
  display_title do
    title 'Getting latest Git commit hash from repository'
  end

  run_command do
    command "git rev-parse --verify HEAD"
    user "root"
    group "root"
    cwd "#{release_path}/"
  end

  run_command do
    command "echo $(git rev-parse --verify HEAD | cut -c1-3)_ > /tmp/latestGitCommitHashPrefix && echo \"New Git Commit Hash Prefix:\" && cat /tmp/latestGitCommitHashPrefix"
    user "root"
    group "root"
    cwd "#{release_path}/"
  end
  
  latestGitCommitHashPrefix = File.read("/tmp/latestGitCommitHashPrefix")
  latestGitCommitHashPrefix=latestGitCommitHashPrefix.delete("\n")

  display_title do
    title 'Set global environment variables'
  end

  output = JSON.parse(OpsWorks::ShellOut.shellout("aws opsworks --region #{region} describe-apps --stack-id #{node[:opsworks][:stack][:id]}"))
  if (output['Apps'][0]['Environment'])
    environmentVariables = output['Apps'][0]['Environment'].dup
    sortedEnvironmentVariables = environmentVariables.sort_by { |k| k['Key'] }
    sortedEnvironmentVariables.each do |envvar|
      display_variable do
        key envvar['Key']
        value envvar['Value']
      end
    end
  end
  
  node.default[:deploy][app_name][:environment_variables] = {
    # @TODO: Barrac, can we remove those variables? Are they used by anyone?
    "MYSQL_HOST"            => (node[:db][:host] rescue nil),
    "MYSQL_PORT"            => '3306',
    "MYSQL_USER"            => (node[:db][:username] rescue nil),
    "MYSQL_PASSWORD"        => (node[:db][:password] rescue nil),
    "MYSQL_DATABASE_NAME"   => (node[:db][:name] rescue nil),
    "REDIS_HOST"            => (node[:elc][:host] rescue nil),
    "REDIS_PORT"            => '6379',
    "HTTPS"                 => 'ON',
    # Artifakt variables
    "ARTIFAKT_MYSQL_HOST" => (node[:db][:host] rescue nil),
    "ARTIFAKT_MYSQL_PORT" => '3306',
    "ARTIFAKT_MYSQL_USER" => (node[:db][:username] rescue nil),
    "ARTIFAKT_MYSQL_PASSWORD" => (node[:db][:password] rescue nil),
    "ARTIFAKT_MYSQL_DATABASE_NAME" => (node[:db][:name] rescue nil),
    "ARTIFAKT_REDIS_HOST" => (node[:elc][:host] rescue nil),
    "ARTIFAKT_REDIS_PORT" => '6379',
    "ARTIFAKT_ENVIRONMENT_NAME" => node[:opsworks][:stack][:name],
    "ARTIFAKT_ENVIRONMENT_CRITICALITY" => node[:stack][:mode],
    "ARTIFAKT_DEPLOYMENT_ID" => (node[:opsworks][:deployment].to_s.gsub('-', '') rescue nil),
    "ARTIFAKT_IS_MAIN_INSTANCE" => (if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance] then "1" else "0" end),
    "ARTIFAKT_LATEST_GIT_COMMIT_HASH_PREFIX" => (latestGitCommitHashPrefix rescue nil),
    "AWS_ES_ENDPOINT" => (node[:app][:aws_es][:endpoint] rescue nil),
    "AWS_ES_USERNAME" => (node[:app][:aws_es][:username] rescue nil),
    "AWS_ES_PASSWORD" => (node[:app][:aws_es][:password] rescue nil),
    "IS_INSTALLED" => (node[:app][:is_installed] rescue nil),
  }

  display_title do
    title 'Set job environment variables'
  end if node[:deploy][node[:app_name]][:environment_variables_job]

  # Duplicate original node to ensure that we don't update something used later on
  hookVariables = node[:deploy][node[:app_name]][:environment_variables].dup;

  if node[:deploy][node[:app_name]][:environment_variables_job]
    jobVariables = node[:deploy][node[:app_name]][:environment_variables_job].dup;
    sortedJobVariables = jobVariables.sort_by { |k| k["key"] }
  end

  # Push custom environment variables to this duplicate node
  sortedJobVariables.each do |variable|
    hookVariables[variable[:key]] = variable[:value]
  end if node[:deploy][node[:app_name]][:environment_variables_job]

  sortedHookVariables = hookVariables.sort

  template "/etc/profile.d/environment.sh" do
    source "environment.erb"
    mode 0664
    owner "root"
    group "root"
    variables ({ :environment => node[:deploy][app_name][:environment_variables] })
  end if node[:deploy][app_name][:environment_variables]

  execute "Export all environnement var from /etc/environment" do
    user node[:app_user]
    group node[:app_group]
    command ". /etc/profile.d/environment.sh"
  end

    # Check if the directory 'current' exists (it doesn't on first install)
    link "/srv/www/#{app_name}/current" do
      to "#{release_path}"
      user node[:app_user]
      group node[:app_group]
      not_if do
        ::File.symlink?("/srv/www/#{app_name}/current")
      end
    end

  if node[:command][:type] == 'setup'
    display_title do
      title 'Execute custom setup script hook'
    end
    if File.exist?("#{release_path}/artifakt/setup.sh")
      run_command do
        command 'sh artifakt/setup.sh'
        owner "root"
        group "root"
        environment hookVariables
        cwd "#{release_path}/"
      end
    else
      display_text do
        text 'No setup.sh hook file found'
      end
    end
  end

  display_title do
    title 'Set right permission to all files and directories'
  end

  bash "Set right permission to all files" do
    cwd "#{release_path}/"
    code <<-EOH
        find . -type f -exec chmod 775 {} \\;
        find . -type d -exec chmod 775 {} \\;
    EOH
  end

  display_title do
    title "Generating application configuration files for App type: #{node[:app][:type]} / App version: #{node[:app][:version]}"
  end
  node[app_type][:config_file].each do |source_file, path_file|
    display_text do
      text "Generated: #{path_file} with #{source_file} for stack #{node[:stack][:type]}"
    end
    template "#{release_path}/#{path_file}" do
      source source_file
      cookbook "artifakt_app_#{app_type}"
      mode 0770
      owner node[:app_user]
      group node[:app_group]
      variables(
        :dbhost => (node[:db][:host] rescue nil),
        :dbuser => (node[:db][:username] rescue nil),
        :dbpassword => (node[:db][:password] rescue nil),
        :dbname => (node[:db][:name] rescue nil),
        :dbprefix => (node[:db][:prefix] rescue nil),
        :cachehost => (node[:elc][:host] rescue nil),
        :redisprefix => (latestGitCommitHashPrefix rescue nil),
        :sessionhost => (node[:elc][:host] rescue nil),
        :appjwtpassphrase => (node[:app][:jwtpassphrase] rescue nil),
        :appsecret => (node[:app][:secret] rescue nil),
        :appfpc => (node[:app][:fpc] rescue nil),
        :appboprefix => (node[:app][:boprefix] rescue nil),
        :smtphost => (node[:email][:host] rescue nil),
        :smtplogin => (node[:email][:login] rescue nil),
        :smtppassword => (node[:email][:password] rescue nil),
        :appurl => (node[:app][:url] rescue nil),
        :stackmode => (node[:stack][:mode] rescue nil),
        :coderoot => (node[:deploy][node[:app][:type]][:absolute_code_root] rescue nil)
      )
    end
  end

  display_title do
    title 'Mount files shared between releases'
  end

  node[:app][:shared_files].each do |shared_file|
    artifakt_file_shared do
      filename shared_file
    end
    display_text do
      text "Mount file: #{shared_file}"
    end
  end

  if File.exist?("#{release_path}/composer.json")
    display_title do
      title 'composer.json file found, installation of dependencies'
    end
    if File.exist?("#{release_path}/auth.json")
      run_command do
        command 'cp -f auth.json /var/www/.composer/auth.json'
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end
    else
      display_text do
        text "No auth.json file found\n"
      end
    end
    
    if node[:composer][:prestissimo] == "true"
      display_text do
        text "Installation of prestissimo to speed up installation process\n"
      end
      execute 'Install prestissimo' do
        user node[:app_user]
        group node[:app_group]
        cwd "#{release_path}/"
        command "COMPOSER_MEMORY_LIMIT=-1 composer global require hirak/prestissimo"
        ignore_failure true
      end
    end

    if node[:app][:composer_install] == "true"
      display_command do
        command 'composer install'
      end
      run_command do
        command "COMPOSER_MEMORY_LIMIT=-1 composer install --ansi #{node[:composer][:extra_params]}"
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end
    end
  end

  if app_type == "magento2"
    display_title do
      title 'Check if directory /mnt/shared/pub/media exists, if not, create it'
    end

    directory '/mnt/shared/pub/media' do
      owner node[:app_user]
      group node[:app_group]
      mode '0777'
      action :create
      recursive true
    end
  end

  display_title do
    title 'Execute custom pre-deploy script hook'
  end

  if File.exist?("#{release_path}/artifakt/pre_deploy.sh")
    run_command do
      command 'sh artifakt/pre_deploy.sh'
      user node[:app_user]
      group node[:app_group]
      environment hookVariables
      cwd "#{release_path}/"
    end
  else
    display_text do
      text 'No pre_deploy.sh hook file found'
    end
  end

  send("#{custom_deploy}")

  display_text do
    text "Check is_installed value - #{node[:app][:is_installed]}"
  end

  if node[:app][:is_installed] == "true"
    display_title do
      title 'Execute custom post-deploy script hook'
    end

    if File.exist?("#{release_path}/artifakt/deploy.sh")
      run_command do
        command 'sh artifakt/deploy.sh'
        user node[:app_user]
        group node[:app_group]
        environment hookVariables
        cwd "#{release_path}/"
      end
    else
      display_text do
        text 'No deploy.sh hook file found'
      end
    end
  end

  display_title do
    title 'Mount directories shared between releases'
  end
  node[app_type][:shared_directories].each do |directory_to_mount|
    artifakt_mount_shared do
      dirname directory_to_mount
    end
    display_text do
      text "Mount directory: #{directory_to_mount}"
    end
  end
end
