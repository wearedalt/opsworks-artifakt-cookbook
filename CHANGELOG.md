# V0.12.20
- Fix:
  - *_Actions_*:
    * Fix permissions on .maintenance.flag for Magento (set to apache:opsworks)

# V0.12.19
- Fix:
  - *_Actions_*:
    * Fix error on safe repository with git, for project without deploy node

# V0.12.18
- Fix:
  - *_Actions_*:
    * Fix error git when getting hash: "fatal: unsafe repository ('xxx is owned by someone else ..."

# V0.12.17
- Fix:
  - *_Actions_*:
    * Fix for expired certificates (run update during setup + during deploy jobs)

# V0.12.16
- Fix:
  - *_Actions_*:
    * Add missing condition variable check

# V0.12.15
- Fix:
  - *_Actions_*:
    * Fix/Force same content version across all stack nodes during M2 `setup:static-content:deploy` cmd
    * Fix deploy sequence for Akeneo 3.0
    * Fix for PHP sodium lib on PHP 7.2 and 7.3
    * Fix/Add checks around db availability during setup jobs, to stabilize operating days and instance(s) reboot
    * Fix M2 default Redis configuration between 2.4 Scalable, and 2.x Starter

# V0.12.14
- Fix:
  - *_Actions_*:
    * Harmonize Magento 2 `env.php` files between versions
    * Add Magento 2 OPcache settings for PHP 7.2 and 7.3
    * Harmonize PHP `post_max_size` setting with `upload_max_filesize` setting
    * Add sodium PHP lib with PHP 7.2
    * Fix `document_root_is_pub` configuration setting to `true`

# V0.12.13
- Fix:
  - *_Actions_*:
    * Add restart always policy to MySQL 8 container for v4 starter environments

# V0.12.12
- Fix:
  - *_Actions_*:
    * Fix the start & stop for Magento 2 on Scalable platforms type

# V0.12.11
- Fix:
  - *_Actions_*:
    * Fix application error logs with Apache, in order for them to be pushed and available from the Console
    * Fix/Bump New Relic agent version
    * Fix `docker-compose up` when already existing containers are in exited state
    * Fix/disable httpd http2 mod
    * Prune after varnish installation
    * Do not prune on fpm restart, only after installation

# V0.12.10
- Fix:
  - *_Actions_*:
    * Fix Magento 2 NGINX map file inclusion for existing instances
- Enhancements:
  - *_Actions_*:
    * Magento 2 - Allow custom commands before and after `setup:static-content:deploy` command (needed with some specific themes compilation)
    * Magento 2 - Allow support of multiple themes with dedicated locales during `setup:static-content:deploy`

# V0.12.9
- Fix:
  - *_Actions_*:
    * Fix `sed` instruction in order to properly replace `newrelic.appname` param when needed, without concatenating issues or no possibility to update already modified value

# V0.12.8
- Fix:
  - *_Actions_*:
    * Fix/Make manageable the `composer dump-autoload` command for Magento 2, which can create issues with some unconventional code/M2 modules
    * Handle custom backends in order to avoid downtimes during Setup jobs when multiple backends/applications are in used by customer

# V0.12.7
- Fix:
  - *_Actions_*:
    * Fix/Add missing Akeneo Apache vhost directive

# V0.12.6
- Fix:
  - *_Actions_*:
    * Fix variable name in default recipe of sftp users

# V0.12.5
- Fix:
  - *_Actions_*:
    * Fix ssh user deletion when removing an access

# V0.12.4
- Fix:
  - *_Actions_*:
    * Make `AKENEO_PIM_URL` variable manageable from custom configurations
    * Add Akeneo Events API missing consumer worker
    * Add `--allow-releaseinfo-change` param to `apt-get update` commands, for PHP-FPM Dockerfile
    * Fix `files_to_stream` param to properly use default defined values

# V0.12.3
- Fix:
  - *_Actions_*:
    * Fix/add supervisor support for Akeneo

# V0.12.2
- Fix:
  - *_Actions_*:
    * Fix/Add missing Akeneo 4 & 5 shared directories

# V0.12.1
- Fix:
  - *_Actions_*:
    * Fix in order to only force Magento 2 NGINX vhost symlink when source file exists, and when a symlink does not already exist

# V0.12.0
- Enhancements:
  - *_Actions_*:
    * Update Magento 2 deploy sequence

# v0.11.0
- Fix:
  - *_Actions_*:
    * Hotfix for Akeneo 4 & 5 regarding the deploy sequence, with a wrong variable usage, which could result to a database reset
    * Fix a ZDT issue during setup job, related to PHP-FPM Docker container and the way volumes were mounted in 2 steps instead of being always declared
    * Fix for refreshing Magento 2 NGINX vhost after release change, in case of newly added NGINX map file, or after the first provisioning of any kind of server
    * Fix some NGINX timeouts regarding Cloudflare timeout configuration (to `600s` instead of misc)
- Enhancements:
  - *_Actions_*:
    * Add PHP 8 support
    * Add some Akeneo 4 & 5 configuration parameters
    * Add a ready-to-use Redis Container for Starter environments, as it is not a managed service anymore for such environment type
    * Add the ability to disable `WP_CRON` if defined from custom JSON
    * Update Varnish VCL regarding latest changes from Magento side (see https://github.com/magento/magento2/pull/28927)

# v0.10.2
- Fix:
  - *_Actions_*:
    * Fix RabbitMQ `docker-compose.yml` template file extension (missing `.erb`)

# v0.10.1
- Fix:
  - *_Actions_*:
    * Fix/Improve Shopware default shared directories

# v0.10.0
- Fix:
  - *_Actions_*:
    * Fix Varnish Magento 2 auto configuration by triggering `configure` recipe before deployment end
    * Remove unnecessary error message regarding ES endpoint/vhost (not needed anymore)
- Enhancements:
  - *_Actions_*:
    * Make Varnish version manageable

# v0.9.4
- Fix:
  - *_Actions_*:
    * Fix RabbitMQ docker-compose file extension to erb

# v0.9.3
- Fix:
  - *_Actions_*:
    * Disable MySQL binary logs on Starter environments (not needed/used, and disk space consuming)
    * Fix ES/RabbitMQ version default param, which was not properly considered when only install flag was declared from the Console
    * Increase first_byte_timeout Varnish parameter to 600s (and btw harmonize with NGINX/PHP/CDN)
    * Fix/add missing param for php 74
    * Add ARTIFAKT_LATEST_GIT_COMMIT_HASH_PREFIX env variable into sudoers env_keep setting
    * Increase default Varnish storage, and make it manageable

# v0.9.2
- Fix:
  - *_Actions_*:
    * Fix a missing parameters template file for OroCommerce (regression from 0.8.0)

# v0.9.1
- Fix:
  - *_Actions_*:
    * Fix Sylius NGINX vhost
    * Fix New Relic installation on non Docker based installation

# v0.9.0
- Enhancements:
  - *_Actions_*:
    * Add Sylius 1.9 support

# v0.8.1
- Fix:
  - *_Actions_*
    * Fix default application configuration file deployment, no matter is_installed` flag

# v0.8.0
- Fix:
  - *_Actions_*
    * Fix OroCommerce supervisor configuration
    * Fix/Update OroCommerce/OroCRM Dockerfile

- Enhancements:
  - *_Actions_*:
    * Add Shopware 6.4 support

# v0.7.2
- Fix:
  - *_Actions_*
    * Remove Xdebug in OroCommerce/OroCRM PHP-FPM Dockerfile
    * Fix OroCommerce/OroCRM NGINX vhost

# v0.7.1
- Fix:
  - *_Actions_*
    * Fix OroCommerce/OroCRM runtimes versions
    * Clean runtimes config recipe
    
# v0.7.0
- Fix:
  - *_Actions_*
    * Fix/add locales packages for PHP-FPM docker container
    * Fix NGINX vhost for Magento 2.4 setup page
    * Fix NGINX vhost files which are not always symlinked
    * Remove Xdebug support for PHP-FPM docker container (performance reasons)

- Enhancements:
  - *_Actions_*:
    * Add OroCommerce 4.2.3 support
    * Add OroCRM 4.2.2 support

# v0.6.3
- Fix:
  - *_Actions_*
    * Fix a wording mistake in a display title
    * Fix unwanted unmount actions during SFTP accounts configuration if multiple users share the same username prefix
    * Fix `app/etc/config.php` file detection and generation

- Enhancements:
  - *_Actions_*:
    * Add Akeneo 4.0 support
    * Add Akeneo 5.0 support 
    * Remove/Deprecate support for Akeneo 3.0 (we still support Akeneo 3.1 and 3.2)
    * Add support for `-—no-dev` or any custom parameters for `composer install` command
    * Add the possibility to share and mount custom SSH keys to PHP-FPM docker container, in order to be able to fetch private git based Composer packages
    * Add sendmail support for PHP-FPM docker container

# v0.6.2
- Fix:
  - *_Actions_*
    * Fix _Clear Cache_ job
    * Add/Fix support for Quanta with docker based PHP 7.4
    * Prevent issues when MySQL is not up & running yet and deploy needs it (cache flush action on Magento 1), by adding a timer/until 'ping OK' mechanism.
    * Add/Fix New Relic support in PHP 7.4 Dockerfile + Use a variable for the agent version
    * Fix to properly hide variables tagged as masked

- Enhancements:
  - *_Actions_*:
    * Fix/Define services versions and parameters for Magento 2
    * Fix/Define services versions and parameters for PHP 7.4 App

# v0.6.1
- Fix:
  - *_Actions_*
      * Make Redis `id_prefix` (for Magento 1/2 cache + FPC entries) immutable per _release_ (based on last commit Git hash)
      * Harmonize Elasticsearch version 7.7.0 as default version on Starter platforms (and fix a mix between 7.6.0 and 7.7.0 versions)
      * Update Magento 2 NGINX vhost to the latest available version (See https://github.com/magento/magento2/blob/2.4-develop/nginx.conf.sample)

- Enhancements:
  - *_Actions_*:
      * Include both `analysis-icu` and `analysis-phonetic` Elasticsearch plugins by default on Starter platforms
      * Switch Elasticsearch service to `docker-compose` on Starter platforms
      * Clean Elasticsearch recipes/cookbooks
      * Add `docker system prune -f` command after Elasticsearch container creation
      * Add `docker system prune -f` command inside and after PHP-FPM container restart action.

# v0.6.0
- Fix:
  - *_Actions_*
      * Fix issues with PHP-FPM 7.4 Docker and mounted volumes when instances restart
      * Fix the NGINX folder name, for `esAWS` vhost
      * Fix Akeneo `console` commands used when app is installed and deployed
      * Fix Akeneo 3.1/3.2 `yarn run webpack` command (Force some dependencies version)
      * Remove a missing dump regarding environment variables

- Enhancements:
  - *_Actions_*:
      * Add PHP-FPM 7.4 support for NGINX using `Custom Variables` in the console
      * Automate PHP-FPM 7.4 installation using Docker
      * Validate Docker image for Magento 2
      * Use wrapper for `php`, `composer`, `magerun` commands
      * Check if main instance before deploying cron jobs
      * Add `restart always` parameter for Elasticsearch
      * Change `max_concurrency` parameter from `6` to `50` in Magento 2 `env.php` file
      * Change `consumers_wait_for_messages` parameter from `1` to `0` in Magento 2 `env.php` file
      * Change `break_after_frontend` parameter from `5` to `30` in Magento 2 `env.php` file
      * Change `disable_locking` parameter from `0` to `1` in Magento 2 `env.php` file
      * Add a missing symlink from `/usr/bin/php` to `/usr/local/bin/php`, in order to avoid issues with some Magento 2 console commands and `Symfony/Component/Process/PhpExecutableFinder.php`/RabbitMQ
      * Force NGINX to re-apply Magento vhost, in case of update (useful when adding a map file for example)
      * Add support for Akeneo 4
      * Add `explicit_defaults_for_timestamp` missing MySQL parameter which is mandatory for Magento 2 in order to be able to do zero downtime deployment
      * Automate Varnish installation in `/srv/www/varnish` through Docker
      * Get all variables to install Varnish and set `http_cache_hosts` Magento 2 configuration
      * Automate configuration update of Varnish
      * Set PHP-FPM 7.4 Docker available for all web-engines (support for Apache and NGINX)
      * Add PHP-FPM in wordpress configuration (`mod_php5_apache2/templates/default/web_app.conf.erb`)
      * Set default MySQL port to `127.0.0.1` for a standard platform for Wordpress runtime on Starter environments
      * Forbid installation of PHP module(s) if PHP 7.4 selected
      * Remove PHP 7 module (`dissmod`) if `web_engine` is apache and language is PHP 7.4
  
# v0.5.9
- Fix:
  - *_Actions_*
      * Fix: wrong service name for clear_cache job (changed from apache2 to httpd)

# v0.5.8
- Fix:
  - *_Actions_*
      * Fix: remove magento and use app_name from artifakt/definitions/artifakt_global_deploy.rb
      * Fix: remove magento and use app_name from artifakt/recipes/setup.rb

# v0.5.7
- Fix:
  - *_Actions_*
      * Fix: don't display variable if nil

# v0.5.6
- Fix:
  - *_Actions_*
      * Fix fastcgi_param in magento2.erb, add double quotes

# v0.5.5
- Fix:
  - *_Actions_*
      * Display variables

- Enhancements:
  - *_Actions_*:
      * Possible to use MAGENTO_LANGUAGES in variables to set other values (default: en_US fr_FR)

# v0.5.4
- Fix:
  - *_Actions_*
      * Fix sftp directory if missing

- Enhancements:
  - *_Actions_*:
      * Nginx Magento 1 & 2 correction (deny var and media execution for php files)
      * Use an Elasticsearch stack (starter: installed locally, pro&entreprise: aws)
      * Deploy Newrelic using variables
      * Directory "current" checked before setup script
      * Create directory "/mnt/shared/media/pub" before pre_deploy if doesn't exists
      * Execute "deploy.sh" script only if is_installed = true

# v0.5.3
- Fix:
  - *_Actions_*
      * Fix rollback by remove old failed releases and check if folder releases exists
      * Fix redis-cli by removing the package (not used by the customer)

- Enhancements:
  - *_Actions_*:
      * Add rollback hook /artifakt/rollback.sh

# v0.5.2
- Fix:
  - *_Actions_*
      * Fix build failed when `node[:composer][:version]` is not set
      * Fix prestissimo

- Enhancements:
  - *_Actions_*:
      * Support Magento 2.4 version
      * Elasticsearch using docker now
      * Support mysql 8.0

# v0.5.1

- Enhancements:
  - *_Actions_*:
      * Add capability to specify the composer version using variables: composer : version

# v0.5.0

- Enhancements:
  - *_Actions_*:
      * Add ARTIFAKT_DEPLOYMENT_ID in environment variables
      * Use ARTIFAKT_DEPLOYMENT_ID for redis prefix
      * Add ARTIFAKT_IS_MAIN_INSTANCE in environment variables

# v0.4.12

- Enhancements:
  - *_Actions_*:
      * Show GIT Hash in deploy log
      * Sort environment variables
      * Add cloudwatch agent installation

# v0.4.11

- Fix:
  - *_Actions_*
      * Mount script modified for EFS, mount command used and information wrote in the FSTAB to keep the "/mnt/shared" folder available after reboot and re-setup
      * For Magento 2, absolute_code_root added to cwd command (for custom configuration) for maintenance scripts (on and off)
      * For Magento 2, stop flushing cache before deploy (failed for new install)

- Enhancements:
  - *_Actions_*:
      * For Magento 1, clear redis cache during deploy
      * For Magento 1, clear redis cache for clear-cache job


# v0.4.10

- Enhancements:
  - *_Actions_*:
      * New recipe artifakt::resize-disk for extend file system after a size modification on EBS
      * Add some default artifakt environment variables (ARTIFAKT_MYSQL_HOST, ARTIFAKT_ENVIRONMENT_NAME, etc)
      * Add capabitity to use custom environments variables during deploy and setup hooks

# v0.4.9

- Fix:
  - *_Actions_*
      * Fix SFTP Access

# v0.4.8

- Fix:
  - *_Actions_*
      * Fix streaming multiple files in one log stream name on CloudwatchLogs does NOT work
      * Fix Magento maintenance.flag path (code root)
- Enhancements:
  - *_Actions_*:
      * Each logs files has its own log stream name on CloudwatchLogs
      * Hide secured environment variable in logs

# v0.4.7

- Fix:
  - *_Actions_*
      * Change SFTP user configuration
      * Disable mysql log general
      * Show True Client IP apache2 and nginx

- Enhancements:
  - *_Actions_*
      * Set Keep release to 3

# v0.4.6

- Fix:
  - *_Actions_*
      * Fix remove app_dev.php for prod
      * Fix health_check nginx for Magento 2
      * Fix restart mysql starter after crashed
      * Fix install supervisor with pip
      * Fix nginx permission logrotate
      * Fix code root nginx Magento 1

- Enhancements:
  - *_Actions_*
      * Empty cache Magento before maintenance
      * Add custom Hook for setup
      * Customize nginx port for magento 2 and varnish
      * Add Environnment variables to nginx
      * Realtime logs for jobs
      * Add Docker package
      * Improve buffer Nginx

# v0.4.5

- Fix:
  - *_Actions_*
      * MySql installation with Nginx
      * Clear Cache Magento with right permission
      * Clear Cache Magento with command cache:flush instead of cache:clean

- Enhancements:
  - *_Actions_*
      * Security Nginx Magento 2 pub/.user.ini
      * Add PHP7.3 and fixing for APCU & Memcache
      * Remove EBS recipes to use new instance types (m5, t3)

# v0.4.4

- Fix:
  - *_Actions_*
      * Quanta agent installation

- Enhancements:
  - *_Actions_*
      * Improve Magento Nginx files
      * Monitor supervisord and mysqld process
      * Improve Apache security

# v0.4.3

- Fix:
  - *_Actions_*
      * Forwarded IP from ELB for nginx

- Enhancements:
  - *_Actions_*
      * Share root files between releases.
      * Install Quanta agento and push deploy notification if token is set
      * Remove server Header Apache

# v0.4.2

- Fix:
  - *_Actions_*
      * Fix buildpack Drupal v7.6
      * Fix buildpack Akeneo (all versions)
      * Fix environment variables not set when running a command with function `run_command`

- Enhancements:
  - *_Actions_*
      * Installation of good version of mysql sent by OpsWork
      * Creation of local database with good charset and collation
      * mysql command and mysqldump are now available for nginx mode
      * Install supervisor for every servers

# v0.4.1

- Fix:
  - *_Actions_*
      * Fix permission of folder `/var/log/mysql` for `mysql` be able to write logs in it
      * Move mount directory at the end of the deploy and remove var shared directory for Magento 2
      * Fix php-fpm PID

- Enhancements:
  - *_Actions_*
      * Improve clear-cache recipe with Magento 2 custom command and Reload web Engine + OpCache
      * Add Reload web Engine + OpCache at the end of the deploy
      * Install Htop


# v0.4.0

- Fix:
  - *_Actions_*:
      * Buildpack PHP
      * Buildpack Symfony
      * Buildpack Drupal (version 8.7)
      * Buildpack Wordpress
      * Buildpack Magento

- Enhancements:
  - *_Architectures_*:
      * Deletion of recipes apps: oro, joomla, marello, orocommerce, prestashop, satis and typo
      * Deletion of recipe artifakt_app_nginxconfig
      * Deletion of `/cookbooks/before_configure` and `/cookbooks/after_setup`

  - *_Actions_*:
      * New way of handle symfony version and symfony based app
      * Display usefull logs for user and output of commands (ex: `composer install` or title like "---> Gettings code")
      * Reconfiguration of cloud watch agent for send good logs files
