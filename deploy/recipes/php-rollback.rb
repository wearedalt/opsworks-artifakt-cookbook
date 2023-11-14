node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::nodejs-rollback for application #{application} as it is not a php app")
    next
  end

  display_title do
    title 'Rollback to previous release'
  end

  deploy deploy[:deploy_to] do
    user deploy[:user]
    action 'rollback'
    restart_command "sleep #{deploy[:sleep_before_restart]} && #{deploy[:restart_command]}"

    only_if do
      File.exists?(deploy[:current_path])
    end
  end

  display_title do
    title 'Run custom rollback script (e.g db migrate)'
  end

  if File.exist?("#{node[:deploy][application][:absolute_code_root]}/artifakt/rollback.sh")
    run_command do
      command 'sh artifakt/rollback.sh'
      user node[:deploy][application][:user]
      group node[:deploy][application][:group]
      cwd "#{node[:deploy][application][:absolute_code_root]}/"
    end
  else
    display_text do
      text 'No rollback.sh hook file found'
    end
  end

end
