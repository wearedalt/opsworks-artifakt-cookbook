###
# This is the place to override the mod_php5_apache2 cookbook's default attributes.
#
# Do not edit THIS file directly. Instead, create
# "mod_php5_apache2/attributes/customize.rb" in your cookbook repository and
# put the overrides in YOUR customize.rb file.
###

php_version = node[:app][:language]
php_version_dot = node[:app][:language_long]
packages = []

case node[:platform_family]
when 'debian'
  packages = [
    "php5-xsl",
    "php5-curl",
    "php5-xmlrpc",
    "php5-sqlite",
    "php5-dev",
    "php5-gd",
    "php5-cli",
    "php5-sasl",
    "php5-mcrypt",
    "php5-intl",
    "php5-memcache",
    "php-pear",
    "php-xml-parser",
    "php-mail-mime",
    "php-db",
    "php-mdb2",
    "php-html-common",
    "php5-mysql"
  ]
when 'rhel'
  packages = [
    "php#{php_version}-xml",
    "php#{php_version}-intl",
    "php#{php_version}-common",
    "php#{php_version}-xmlrpc",
    "php#{php_version}-gd",
    "php#{php_version}-cli",
    "php#{php_version}-mcrypt",
    "php#{php_version}-pecl-apcu",
    "php#{php_version}",
    "php#{php_version}-devel",
    "php#{php_version}-opcache",
    "php#{php_version}-mbstring",
    "php#{php_version}-bcmath",
    "php#{php_version}-soap",
    "php#{php_version}-mysqlnd"
  ]
when 'ubuntu'
packages = [
    "php#{php_version_dot}-xml",
    "php#{php_version_dot}-intl",
    "php#{php_version_dot}-common",
    "php#{php_version_dot}-xmlrpc",
    "php#{php_version_dot}-gd",
    "php#{php_version_dot}-cli",
    "php#{php_version_dot}-mcrypt",
    "php#{php_version_dot}-memcached",
    "php#{php_version_dot}-apcu",
    "php#{php_version_dot}",
    "php#{php_version_dot}-devel",
    "php#{php_version_dot}-opcache",
    "php#{php_version_dot}-mbstring",
    "php#{php_version_dot}-bcmath",
    "php#{php_version_dot}-soap",
    "php#{php_version_dot}-mysqlnd"
]
end

if php_version == "70"
  packages.push("php#{php_version}-zip")
end

if php_version != "71w"
  packages.push("php#{php_version}-pecl-memcache")
end

if php_version == "72"
  packages.delete("php#{php_version}-mcrypt")
end

if php_version == "73"
  packages.delete("php#{php_version}-mcrypt")
  packages.delete("php#{php_version}-pecl-apcu")
  packages.delete("php#{php_version}-pecl-memcache")
end

if php_version == "54"
  packages.delete("php#{php_version}-pecl-apcu")
  packages.delete("php#{php_version}-opcache")
end

default[:mod_php5_apache2][:packages] = packages
