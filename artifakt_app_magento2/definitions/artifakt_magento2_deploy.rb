#
# Cookbook Name: artifakt_app_magento2
# Definition: artifakt_magento2_deploy
#

define :artifakt_magento2_deploy  do
  release_path = node[:app_release_path]

  # First, we get latest git commit hash, then, we extract only numbers from it, and finally, we grab only the first 10 chars
  staticVersionFromLatestGitHash = OpsWorks::ShellOut.shellout(
    "echo $(git rev-parse --verify HEAD)",
     :cwd => "#{release_path}/"
   ).strip.delete("^0-9")[0, 10];

  if node[:deploy][node[:app_name]][:environment_variables]['MAGENTO_LANGUAGES']
    display_text do
      text "MAGENTO LANGUAGES FOUND: #{node[:deploy][node[:app_name]][:environment_variables]['MAGENTO_LANGUAGES']}"
    end
    node.default[:magento2][:languages] = node[:deploy][node[:app_name]][:environment_variables]['MAGENTO_LANGUAGES']
  end

  display_text do
    text "Deploy Magento 2 for App type: #{node[:app][:type]} / App version: #{node[:app][:version]}"
  end

  bash "Create symlink for maintenance" do
    user "root"
    cwd "#{release_path}/"
    code <<-EOH
      mkdir -p ./var
      mkdir -p /mnt/shared/var
      chmod 775 ./var
      chmod 777 /mnt/shared/var
      chown #{node[:app_user]}:#{node[:app_group]} ./var
      chown #{node[:app_user]}:#{node[:app_group]} /mnt/shared/var
      ln -sf /mnt/shared/var/.maintenance.flag ./var/.maintenance.flag
      EOH
  end

  execute 'Permission bin/magento' do
    cwd "#{release_path}/"
    command "chmod u+x bin/magento"
  end

  execute "Remove env.php is not installed" do
    cwd "#{release_path}/"
    command "rm -f app/etc/env.php"
    only_if { node[:app][:is_installed] == 'false' }
  end

  display_title do
    title "Check database availability status"
  end
  run_command do
    command 'until [ "$(mysqladmin ping -h $ARTIFAKT_MYSQL_HOST -u $ARTIFAKT_MYSQL_USER -p$ARTIFAKT_MYSQL_PASSWORD)" == "mysqld is alive" ]; do sleep 10 && echo "Database not ready yet, waiting ..."; done; echo "Database ready"'
    user node[:app_user]
    group node[:app_group]
    ignore_failure true
    environment node[:deploy][node[:app_name]][:environment_variables]
  end

  if node[:stack][:type] != 'standard' && node[:command][:type] == 'setup' && node[:operating_days] && node[:operating_days][:enabled] && node[:operating_days][:enabled] == 'true'
    display_title do
      title "Double check database availability status"
    end
    # Sometimes, DB is restarted again just after the initial reboot from operating days, and became back unavailable for few seconds
    # The following will make sure the DB is properly up and running after some consecutive successful tries and reasonable delay
    bash "Make sure database is up and running for some time" do
      code <<-EOH
        db_counter=0
        SECONDS=0
        sleep 300
        until [ $db_counter -eq 3 ]; do
          if [ "$(mysqladmin ping -h #{node[:db][:host]} -u #{node[:db][:username]} -p#{node[:db][:password]})" == "mysqld is alive" ]; then
            (( db_counter++ ))
          else
            db_counter=0
          fi
          sleep 30
          if [ $SECONDS -ge 900 ]; then
            echo "Database unavailable"
            exit 1
          fi
        done
      EOH
    end
  end

  if node[:app][:is_installed] == 'true'
    display_title do
      title "Checking 'app/etc/config.php' file"
    end
    run_command do
      command 'if [ ! -f "app/etc/config.php" ]; then echo "File not found, running generation." && php bin/magento module:enable --all; else echo "File already exists."; fi'
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    if node[:stack][:mode] == 'dev'
      # Mode
      display_command do
        command "php bin/magento deploy:mode:set developer -s"
      end
      run_command do
        command 'php bin/magento deploy:mode:set developer -s'
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end
    end

    if node[:stack][:mode] == 'prod'
      # Mode
      display_command do
        command "php bin/magento deploy:mode:set production -s"
      end
      run_command do
        command 'php bin/magento deploy:mode:set production -s'
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end

      # DI compilation
      display_command do
        command "php bin/magento setup:di:compile"
      end
      run_command do
        command 'php bin/magento setup:di:compile'
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end

      if node[:composer][:dump_autoload] == "true"
        # Composer optimize autoload
        display_command do
          command "composer dump-autoload --optimize --apcu"
        end
        run_command do
          command 'composer dump-autoload --optimize --apcu'
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      end

      # Static deploy - Before
      if node[:magento2][:before_static_cmd]
        display_command do
          command "#{node[:magento2][:before_static_cmd]}"
        end
        run_command do
          command "#{node[:magento2][:before_static_cmd]}"
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      end

      # Static deploy
      if node[:magento2][:themes]
        node[:magento2][:themes].each do |theme, languages|
          display_command do
            command "php bin/magento setup:static-content:deploy #{languages} --theme=#{theme} --content-version=#{staticVersionFromLatestGitHash} --ansi --no-interaction  --jobs 5"
          end
          run_command do
            command "php bin/magento setup:static-content:deploy #{languages} --theme=#{theme} --content-version=#{staticVersionFromLatestGitHash} --ansi --no-interaction  --jobs 5"
            user node[:app_user]
            group node[:app_group]
            environment node[:deploy][node[:app_name]][:environment_variables]
            cwd "#{release_path}/"
          end
        end
      else
        display_command do
          command "php bin/magento setup:static-content:deploy #{node[:magento2][:languages]} --content-version=#{staticVersionFromLatestGitHash} --ansi --no-interaction  --jobs 5"
        end
        run_command do
          command "php bin/magento setup:static-content:deploy #{node[:magento2][:languages]} --content-version=#{staticVersionFromLatestGitHash} --ansi --no-interaction --jobs 5"
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      end

      # Static deploy - After
      if node[:magento2][:after_static_cmd]
        display_command do
          command "#{node[:magento2][:after_static_cmd]}"
        end
        run_command do
          command "#{node[:magento2][:after_static_cmd]}"
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      end
    end

    if node[:opsworks][:main_instance]
      if node[:opsworks][:instance][:hostname] == node[:opsworks][:main_instance]
        # Main instance: Check and upgrade DB and/or import configuration under maintenance, if needed
        display_title do
          title 'Enable maintenance if needed'
        end
        run_command do
          command 'if [[ "$(bin/magento setup:db:status)" != "All modules are up to date." || "$(bin/magento app:config:status)" != "Config files are up to date." ]]; then \
                touch /mnt/shared/var/.maintenance.flag && \
                php bin/magento cache:flush full_page &&  \
                echo "Maintenance enabled."; \
            else echo "Database and configuration are already up to date, no maintenance needed."; fi'
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end

        display_title do
          title 'Update database if needed'
        end
        run_command do
          command 'if [ "$(bin/magento setup:db:status)" != "All modules are up to date." ]; then \
                php bin/magento setup:db-schema:upgrade --no-interaction && \
                php bin/magento setup:db-data:upgrade --no-interaction && \
                echo "Database is now up to date."; \
            else echo "Database is already up to date."; fi'
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end

        display_title do
          title 'Import configuration if needed'
        end
        run_command do
          command 'if [ "$(bin/magento app:config:status)" != "Config files are up to date." ]; then \
                php bin/magento app:config:import --no-interaction && \
                echo "Configuration is now up to date."; \
            else echo "Configuration is already up to date."; fi'
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end

        display_title do
          title 'Disable maintenance if needed'
        end
        run_command do
          command 'if [ -f "/mnt/shared/var/.maintenance.flag" ]; then rm /mnt/shared/var/.maintenance.flag && echo "Maintenance disabled."; else echo "No maintenance activated, skipping."; fi'
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      else
        # Non main instance: Wait until DB is up to date
        display_title do
          title 'Waiting for database and configuration to be up to date'
        end
        run_command do
          command 'echo "All modules are up to date.""'
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      end
    end

    if node[:command][:type] != 'setup'
      display_command do
        command "php bin/magento cache:flush"
      end
      run_command do
        command 'php bin/magento cache:flush'
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end
    end
  end
end