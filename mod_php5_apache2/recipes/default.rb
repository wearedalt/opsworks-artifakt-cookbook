include_recipe 'apache2'

if (node[:app][:language] != "74" && node[:app][:language][0] != '8')
  node[:mod_php5_apache2][:packages].each do |pkg|
    package pkg do
      action :install
      ignore_failure(pkg.to_s.match(/^php-pear-/) ? true : false) # some pear packages come from EPEL which is not always available
      retries 3
      retry_delay 5
    end
  end
end

if node[:app][:language] == "72" || node[:app][:language] == "73"
  bash "EPEL/Remi repository configuration packages" do
    code <<-EOH
      mv -f /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6.bkp
      yum reinstall -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
      mv -f /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6.bkp /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
      yum reinstall -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm || yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    EOH
  end

  bash "PHP #{node[:app][:language_long]} - Fix for Sodium" do
    code <<-EOH
      yum install -y php#{node[:app][:language]}-php-sodium --enablerepo remi-php#{node[:app][:language]}
      cp -n /opt/remi/php#{node[:app][:language]}/root/usr/lib64/php/modules/sodium.so /usr/lib64/php/#{node[:app][:language_long]}/modules/
      bash -c "echo extension=sodium.so > /etc/php-#{node[:app][:language_long]}.d/20-sodium.ini"
    EOH
  end
end

if node[:app][:language] == "73"
  bash "PHP #{node[:app][:language_long]} - Fix for APCu and Memcache" do
    code <<-EOH
      yum install -y php#{node[:app][:language]}-php-pecl-apcu php#{node[:app][:language]}-php-pecl-memcache --enablerepo remi-php#{node[:app][:language]}
      cp -n /opt/remi/php#{node[:app][:language]}/root/usr/lib64/php/modules/apcu.so /usr/lib64/php/#{node[:app][:language_long]}/modules/
      cp -n /opt/remi/php#{node[:app][:language]}/root/usr/lib64/php/modules/memcache.so /usr/lib64/php/#{node[:app][:language_long]}/modules/
      bash -c "echo extension=apcu.so > /etc/php-#{node[:app][:language_long]}.d/10-apcu.ini"
      bash -c "echo extension=memcache.so > /etc/php-#{node[:app][:language_long]}.d/10-memcache.ini"

      rm -rf /usr/lib64/php/7.3/modules/curl.so
      cp -n /opt/remi/php73/root/usr/lib64/php/modules/curl.so /usr/lib64/php/7.3/modules/
    EOH
  end
end

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end
  next if node[:deploy][application][:database].nil?

  bash "Enable network database access for httpd" do
    boolean = "httpd_can_network_connect_db"
    user "root"
    code <<-EOH
      semanage boolean --modify #{boolean} --on
    EOH
    not_if { OpsWorks::ShellOut.shellout("/usr/sbin/getsebool #{boolean}") =~ /#{boolean}\s+-->\s+on\)/ }
    only_if { platform_family?("rhel") && ::File.exist?("/usr/sbin/getenforce") && OpsWorks::ShellOut.shellout("/usr/sbin/getenforce").strip == "Enforcing" }
  end

  case node[:deploy][application][:database][:type]
  when "postgresql"
    include_recipe 'mod_php5_apache2::postgresql_adapter'
  else # mysql or just backwards compatible
    include_recipe 'mod_php5_apache2::mysql_adapter'
  end
end

if (node[:app][:language] != "74" && node[:app][:language][0] != '8')
  include_recipe 'apache2::mod_php5'
end
