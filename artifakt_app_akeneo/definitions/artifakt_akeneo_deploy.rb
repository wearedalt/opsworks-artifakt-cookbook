#
# Cookbook Name: artifakt_app_akeneo
# Definition: artifakt_akeneo_deploy
#

define :artifakt_akeneo_deploy  do
  release_path = node[:app_release_path]
  env = "--env=#{node[:stack][:mode]}"

  # 4.x & 5.x
  # @see https://github.com/akeneo/pim-community-dev/blob/4.0/std-build/Makefile
  # @see https://github.com/akeneo/pim-community-dev/blob/5.0/std-build/Makefile
  if node[:app][:version].slice(0..0) == '4' || node[:app][:version].slice(0..0) == '5'
    # override .env file
    display_text do
      text 'Update .env file'
    end
    run_command do
      command "[[ -e .env.artifakt ]] && cp .env.artifakt .env"
      user node[:app_user]
      group node[:app_group]
      cwd "#{release_path}/"
    end

    # tweak
    run_command do
      command "sed -i -e 's/8.0.18/8.0.17/g' vendor/akeneo/pim-community-dev/src/Akeneo/Platform/PimRequirements.php"
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    # dependencies
    display_command do
      command 'PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 yarn install'
    end
    run_command do
      command 'PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 yarn install'
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    # cache
    display_command do
      command "NO_DOCKER=true make cache"
    end
    run_command do
      command "NO_DOCKER=true make cache"
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    # assets
    display_command do
      command 'NO_DOCKER=true make assets'
    end
    run_command do
      command 'NO_DOCKER=true make assets'
      user node[:app_user]
      group node[:app_group]
      cwd "#{release_path}/"
    end

    # dsm
    if node[:app][:version].slice(0..0) == '5'
      display_command do
        command 'NO_DOCKER=true make dsm'
      end
      run_command do
        command 'NO_DOCKER=true make dsm'
        user node[:app_user]
        group node[:app_group]
        cwd "#{release_path}/"
      end
    end

    # javascript
    display_command do
      command "NO_DOCKER=true make javascript-#{node[:stack][:mode]}"
    end
    run_command do
      command "NO_DOCKER=true make javascript-#{node[:stack][:mode]}"
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    # css
    display_command do
      command 'NO_DOCKER=true make css'
    end
    run_command do
      command 'NO_DOCKER=true make css'
      user node[:app_user]
      group node[:app_group]
      cwd "#{release_path}/"
    end

    # javascript-extensions
    if node[:app][:version].slice(0..0) == '5'
      display_command do
        command 'NO_DOCKER=true make javascript-extensions'
      end
      run_command do
        command 'NO_DOCKER=true make javascript-extensions'
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}"
      end
    end

    if node[:app][:is_installed] == 'false'
      if node[:stack][:mode] == 'dev'
        # Be very careful about this command line! It must be run once, in the first setup
        # This command, drop the database, and recreate a new one
        display_command do
          command "php bin/console pim:installer:db #{env} --catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/icecat_demo_dev"
        end
        run_command do
          command "php bin/console pim:installer:db #{env} --catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/icecat_demo_dev"
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      end
      if node[:stack][:mode] == 'prod'
        # Be very careful about this command line! It must be run once, in the first setup
        # This command, drop the database, and recreate a new one
        display_command do
          command "php bin/console pim:installer:db #{env} --catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/minimal"
        end
        run_command do
          command "php bin/console pim:installer:db #{env} --catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/minimal"
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end

        # Default admin user (not present by default anymore)
        display_command do
          command "php bin/console pim:user:create admin admin support@example.com Super Admin en_US --admin -n #{env}"
        end
        run_command do
          command "php bin/console pim:user:create admin admin support@example.com Super Admin en_US --admin -n #{env}"
          user node[:app_user]
          group node[:app_group]
          environment node[:deploy][node[:app_name]][:environment_variables]
          cwd "#{release_path}/"
        end
      end
    end
  end

########################################################################################################################

  # 3.0, 3.1 & 3.2
  if node[:app][:version].slice(0..0) == '3'
    display_command do
      command 'yarn install'
    end
    run_command do
      command 'yarn install'
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    display_command do
      command "php bin/console cache:clear --no-warmup #{env}"
    end
    run_command do
      command "php bin/console cache:clear --no-warmup #{env} --ansi"
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    display_command do
      command "php bin/console pim:installer:assets --symlink #{env}"
    end
    run_command do
      command "php bin/console pim:installer:assets --symlink #{env} --ansi"
      user node[:app_user]
      group node[:app_group]
      environment node[:deploy][node[:app_name]][:environment_variables]
      cwd "#{release_path}/"
    end

    if node[:app][:is_installed] == 'false'
      # Be very careful about this command line! It must be run once, in the first setup
      # This command, drop the database, and recreate a new one
      display_command do
        command "php bin/console pim:install --force --symlink #{env}"
      end
      run_command do
        command "php bin/console pim:install --force --symlink #{env} --ansi"
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end
    end

    if node[:app][:version] != '3.0'
      display_command do
        command 'Force some dependencies version'
      end
      run_command do
        command 'yarn add typescript@3.6.5 @types/underscore@1.8.3 @types/backbone@1.4.5'
        user node[:app_user]
        group node[:app_group]
        environment node[:deploy][node[:app_name]][:environment_variables]
        cwd "#{release_path}/"
      end
    end

    display_command do
      command 'yarn run webpack'
    end
    run_command do
      command 'yarn run webpack'
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
        command 'php bin/console do:sc:up --force --ansi'
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
end