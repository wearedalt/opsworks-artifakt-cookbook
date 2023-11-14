package 'mysql' do
  package_name value_for_platform_family(
     'rhel' => 'mysql',
     'debian' => 'mysql-client'
  )
  retries 3
  retry_delay 5
end

  if(node[:app][:language][0] == '7' || node[:app][:language][0] == "8")
    if(node[:app][:language][0] == '7' && node[:app][:language][1] != '4')
      package "php-mysql" do
        action :remove
      end
      package "php#{node[:app][:language]}-mysqlnd" do
      action :install
      retries 3
      retry_delay 5
      end
    end
  else
    package 'php-mysql' do
      package_name value_for_platform_family(
        'rhel' => "php#{node[:app][:language]}-mysqlnd",
        'debian' => 'php5-mysql'
      )
      retries 3
      retry_delay 5
    end
  end

if node[:stack][:type] == 'standard'
  display_title do
    title "Selected Mysql Version for Standard platform: #{node[:mysql][:version]}"
  end
  
  if node[:mysql][:version] == '5.5'
    package 'mysql55-server' do
      retries 3
      retry_delay 5
    end
  elsif node[:mysql][:version] == '5.6'
    package 'mysql56-server' do
      retries 3
      retry_delay 5
    end
  elsif node[:mysql][:version] == '5.7'
    package 'mysql57-server' do
      retries 3
      retry_delay 5
    end
  elsif node[:mysql][:version] == '8.0'
    display_text do
      text "Mysql version 8.0 will be installed as Docker container."
    end
  else
    display_text do
      text "Mysql version provided does not match any versions installable on this server"
    end
  end

  if (node[:mysql][:version] != '8.0')
    include_recipe 'mysql::config'

    template "/var/tmp/init_mysql.sql" do
      source 'init_mysql.sql.erb'
      cookbook "mod_php5_apache2"
      mode 0755
      owner 'root'
      group 'root'
      variables(
        :dbuser =>          (node[:db][:username] rescue nil),
        :dbpassword =>      (node[:db][:password] rescue nil),
        :dbname =>          (node[:db][:name] rescue nil),
        :mysql_charset =>   node[:mysql][:charset],
        :mysql_collation => node[:mysql][:collation]
      )
    end

    execute "Remove mysql sock before restart" do
      user 'root'
      command "rm -rf /var/lib/mysql/mysql.sock /var/lib/mysql/mysql.sock.lock"
    end

    service 'mysqld' do
      action :restart
    end

    execute 'Init mysql' do
      user 'root'
      command "mysql < /var/tmp/init_mysql.sql"
    end
  else
    bash "Install mysql server 8.0" do
      code <<-EOH
      echo "Starting setup of Mysql 8.0 server"
      docker stop mysql80
      docker rm mysql80
      mkdir -p /mnt/shared/mysql-conf
      echo [mysqld] > /mnt/shared/mysql-conf/my.cnf
      echo default-authentication-plugin=mysql_native_password >> /mnt/shared/mysql-conf/my.cnf
      echo log_bin_trust_function_creators=1 >> /mnt/shared/mysql-conf/my.cnf
      echo "sql-mode=\"NO_ENGINE_SUBSTITUTION\"" >> /mnt/shared/mysql-conf/my.cnf
      echo skip-log-bin >> /mnt/shared/mysql-conf/my.cnf

      if ! grep -q protocol "/etc/my.cnf"
      then  
        echo "" >> /etc/my.cnf
        echo [client] >> /etc/my.cnf
        echo protocol=tcp  >> /etc/my.cnf  
      fi

      docker run --restart always --volume=/mnt/shared/mysql-data:/var/lib/mysql --volume=/mnt/shared/mysql-conf:/etc/mysql/conf.d --name mysql80 -e MYSQL_USER=#{node[:db][:username]} -e MYSQL_PASSWORD=#{node[:db][:password]} -e MYSQL_DATABASE=#{node[:db][:name]} -e MYSQL_ROOT_PASSWORD=#{node[:db][:password]} -p 3306:3306 -d mysql:8.0
      EOH
    end
  end
end
