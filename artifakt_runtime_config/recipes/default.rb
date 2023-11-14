display_text do
    text 'COOKBOOK - artifakt_runtime_config / recipes / default.rb'
end

node_checker={
    'composer_version' => false,
    'composer_prestissimo' => false,
    'composer_extra_params' => false,
    'composer_dump_autoload' => false,
    'composer_install' => false,
    'web_engine' => false,
    'language' => false,
    'supervisor' => false,
    'std_elasticsearch_installed' => false,
    'std_elasticsearch_version' => false,
    'std_rabbitmq_installed' => false,
    'std_rabbitmq_version' => false,
    'std_redis_installed' => false,
    'std_redis_version' => false,
    'std_database_version' => false,
    'is_installed' => false
}

runtimeConfiguration={
    'akeneo' => {
        '4.0' => {
            'composer_version' => '1.10.22',
            'composer_prestissimo' => 'true',
            'composer_install' => 'true',
            'composer_extra_params' => '',
            'std_database_host' => '127.0.0.1'
        },
        '5.0' => {
            'composer_version' => '2.0.14',
            'composer_prestissimo' => 'false',
            'composer_install' => 'true',
            'composer_extra_params' => '',
            'std_database_host' => '127.0.0.1'
        }
    },
    'magento2' => {
        '2.4' => {
            'composer_version' => '1.10.22',
            'composer_install' => 'true',
            'composer_dump_autoload' => 'true',
            'composer_prestissimo' => 'false',
            'web_engine' => 'nginx',
            'std_elasticsearch_installed' => 'true',
            'std_elasticsearch_version' => '7.9.0',
            'std_redis_version' => '6.0.14',
            'std_database_host' => '127.0.0.1'
        }
    },
    'phpapp' => {
        '7.4' => {
            'language' => '74',
            'language_long' => '7.4',
            'composer_version' => '2.0.14',
            'composer_prestissimo' => 'false',
            'web_engine' => 'nginx',
            'composer_extra_params' => '',
            'std_database_host' => '127.0.0.1'
        },
        '8.0' => {
            'language' => '80',
            'language_long' => '8.0',
            'composer_version' => '2.1.3',
            'composer_prestissimo' => 'false',
            'web_engine' => 'nginx',
            'composer_extra_params' => '',
            'std_database_host' => '127.0.0.1'
        }
    },
    'orocommerce' => {
        '4.2' => {
            'composer_version' => '2.0.14',
            'composer_prestissimo' => 'false',
            'composer_install' => 'false',
            'supervisor' => 'true',
            'web_engine' => 'nginx',
            'std_elasticsearch_installed' => 'true',
            'std_elasticsearch_version' => '7.9.0',
            'std_rabbitmq_installed' => 'true',
            'std_rabbitmq_version' => '3.8',
            'std_database_host' => '127.0.0.1',
            'std_database_version' => '8.0'
        }
    },
    'orocrm' => {
        '4.2' => {
            'composer_version' => '2.0.14',
            'composer_prestissimo' => 'false',
            'composer_install' => 'false',
            'supervisor' => 'true',
            'web_engine' => 'nginx',
            'std_elasticsearch_installed' => 'true',
            'std_elasticsearch_version' => '7.9.0',
            'std_rabbitmq_installed' => 'true',
            'std_rabbitmq_version' => '3.8',
            'std_database_host' => '127.0.0.1',
            'std_database_version' => '8.0'
        }
    },
    'shopware' => {
        '6.4' => {
            'language' => '74',
            'language_long' => '7.4',
            'composer_version' => '2.0.14',
            'composer_prestissimo' => 'false',
            'composer_install' => 'false',
            'supervisor' => 'false',
            'web_engine' => 'nginx',
            'std_elasticsearch_installed' => 'true',
            'std_elasticsearch_version' => '7.9.0',
            'std_rabbitmq_installed' => 'true',
            'std_rabbitmq_version' => '3.8',
            'std_database_host' => '127.0.0.1',
            'std_database_version' => '8.0'
        }
    },
    'symfony' => {
        '4.4' => {
            'composer_extra_params' => '',
            'std_database_host' => '127.0.0.1'
        }
    },
    'wordpress' => {
        '5.2' => {
            'std_database_host' => '127.0.0.1'
        },
        '5.6' => {
            'std_database_host' => '127.0.0.1'
        },
        '5.7' => {
            'std_database_host' => '127.0.0.1'
        },
    },
    'sylius' => {
        '1.9' => {
            'language' => '74',
            'language_long' => '7.4',
            'web_engine' => 'nginx',
            'composer_version' => '2.0.14',
            'composer_prestissimo' => 'false',
            'composer_install' => 'false',
            'std_database_host' => '127.0.0.1',
            'std_database_version' => '8.0'
        }
    },
}

# Checking if values are already declared in node to avoid override
if node.has_key?('composer')
    if node[:composer].has_key?('version')
        node_checker['composer_version'] = true
    end
    if node[:composer].has_key?('prestissimo')
        node_checker['composer_prestissimo'] = true
    end
    if node[:composer].has_key?('extra_params')
        node_checker['composer_extra_params'] = true
    end
    if node[:composer].has_key?('dump_autoload')
        node_checker['composer_dump_autoload'] = true
    end
end

if node.has_key?('app')
    if node[:app].has_key?('language')
        node_checker['language'] = true
    end 
    if node[:app].has_key?('web_engine')
        node_checker['web_engine'] = true
    end
    if node[:app].has_key?('composer_install')
        node_checker['composer_install'] = true
    end  
    if node[:app].has_key?('is_installed')
        node_checker['is_installed'] = true
    end      
end

if node.has_key?('supervisor')
    if node[:supervisor].has_key?('installed')
        node_checker['supervisor'] = true
    end 
end

if node.has_key?('es')
    if node[:es].has_key?('installed')
        node_checker['std_elasticsearch_installed'] = true
    end
    if node[:es].has_key?('version_es')
        node_checker['std_elasticsearch_version'] = true
    end
end

if node.has_key?('rabbitmq')
    if node[:rabbitmq].has_key?('installed')
        node_checker['std_rabbitmq_installed'] = true
    end
    if node[:rabbitmq].has_key?('version')
        node_checker['std_rabbitmq_version'] = true
    end
end

if node.has_key?('redis')
    if node[:redis].has_key?('installed')
        node_checker['std_redis_installed'] = true
    end
    if node[:redis].has_key?('version')
        node_checker['std_redis_version'] = true
    end
end

if node.has_key?('mysql')
    if node[:mysql].has_key?('version')
        node_checker['std_database_version'] = true
    end 
end

# Using defaults values if not configured in the node 
if runtimeConfiguration.has_key?(node[:app][:type])
    if runtimeConfiguration[node[:app][:type]].has_key?(node[:app][:version])
        display_text do
            text 'Auto configuration started for app and version (found in json)'
        end
        currentRuntime=runtimeConfiguration[node[:app][:type]][node[:app][:version]]
        
        if currentRuntime.has_key?('composer_version') && ! node_checker['composer_version']
            node.override[:composer][:version] = currentRuntime['composer_version']
        end

        if currentRuntime.has_key?('composer_prestissimo') && ! node_checker['composer_prestissimo']
            node.override[:composer][:prestissimo] = currentRuntime['composer_prestissimo']
        end

        if currentRuntime.has_key?('composer_extra_params') && ! node_checker['composer_extra_params']
            node.override[:composer][:extra_params] = currentRuntime['composer_extra_params']
        end

        if currentRuntime.has_key?('composer_dump_autoload') && ! node_checker['composer_dump_autoload']
            node.override[:composer][:dump_autoload] = currentRuntime['composer_dump_autoload']
        end

        if currentRuntime.has_key?('composer_install') && ! node_checker['composer_install']
            node.override[:app][:composer_install] = currentRuntime['composer_install']
        end

        if currentRuntime.has_key?('language') && ! node_checker['language']
            node.override[:app][:language] = currentRuntime['language']
            node.override[:app][:language_long] = currentRuntime['language_long']
        end
        
        if currentRuntime.has_key?('web_engine') && ! node_checker['web_engine']
            node.override[:app][:web_engine] = currentRuntime['web_engine']
        end
        
        if currentRuntime.has_key?('supervisor') && ! node_checker['supervisor']
            node.override[:supervisor][:installed] = currentRuntime['supervisor']
        end

        if node[:stack][:type] == 'standard' 
            display_text do
                text 'Standard stack detected'
            end
            if (currentRuntime.has_key?('std_rabbitmq_installed')) && ! node_checker['std_rabbitmq_installed']
                node.override[:rabbitmq][:installed] = currentRuntime['std_rabbitmq_installed']
            end
            if (currentRuntime.has_key?('std_rabbitmq_version')) && ! node_checker['std_rabbitmq_version']
                node.override[:rabbitmq][:version] = currentRuntime['std_rabbitmq_version']
            end

            if (currentRuntime.has_key?('std_redis_installed')) && ! node_checker['std_redis_installed']
                node.override[:redis][:installed] = currentRuntime['std_redis_installed']
            end
            if (currentRuntime.has_key?('std_redis_version')) && ! node_checker['std_redis_version']
                node.override[:redis][:version] = currentRuntime['std_redis_version']
            end

            if currentRuntime.has_key?('std_elasticsearch_installed') && ! node_checker['std_elasticsearch_installed']
                node.override[:es][:installed] = currentRuntime['std_elasticsearch_installed']
            end

            if currentRuntime.has_key?('std_elasticsearch_version') && ! node_checker['std_elasticsearch_version']
                node.override[:es][:version_es] = currentRuntime['std_elasticsearch_version']
            end
            
            if currentRuntime.has_key?('std_database_host')
                node.override[:db][:host] = currentRuntime['std_database_host']
            end

            if currentRuntime.has_key?('std_database_version') && ! node_checker['std_database_version']
                node.override[:mysql][:version] = currentRuntime['std_database_version']
            end
        end
    end
end

# Set default values if not previously set
if node.has_key?('composer')
    if ! node[:composer].has_key?('version')
        node.override[:composer][:version] = "1.10.22"
    end
    if ! node[:composer].has_key?('prestissimo')
        node.override[:composer][:prestissimo] = "true"
    end
    if ! node[:composer].has_key?('extra_params')
        node.override[:composer][:extra_params] = '--no-dev'
    end
    if ! node[:composer].has_key?('dump_autoload')
        node.override[:composer][:dump_autoload] = "true"
    end
else
    node.override[:composer][:version] = "1.10.22"
    node.override[:composer][:prestissimo] = "true"
    node.override[:composer][:extra_params] = '--no-dev'
    node.override[:composer][:dump_autoload] = "true"
end

if node.has_key?('app')
    if ! node[:app].has_key?('web_engine')
        node.override[:app][:web_engine] = "apache"
    end    

    if ! node[:app].has_key?('sync_ssh_keys')
        node.override[:app][:sync_ssh_keys] = "false"
    end

    if ! node[:app].has_key?('composer_install')
        node.override[:app][:composer_install] = "true"
    end

    if ! node[:app].has_key?('is_installed')
        node.override[:app][:is_installed] = "true"
    end
else
    node.override[:app][:web_engine] = "apache"
    node.override[:app][:sync_ssh_keys] = "false"
    node.override[:app][:composer_install] = "true"
    node.override[:app][:is_installed] = "true"
end

if node.has_key?('php_fpm')
    if ! node[:php_fpm].has_key?('install_sendmail')
        node.override[:php_fpm][:install_sendmail] = "false"
    end    
else
    node.override[:php_fpm][:install_sendmail] = "false"
end

if ! node.has_key?('supervisor')
    node.override[:supervisor][:installed] = "false"
end

if ! node.has_key?('es')
    node.override[:es][:installed] = "false"
end

if ! node.has_key?('rabbitmq')
    node.override[:rabbitmq][:installed] = "false"
end

if node.has_key?('redis')
    if node[:redis].has_key?('installed') && node[:redis][:installed] == 'true'
        node.override[:elc][:host] = "127.0.0.1"
    end
end
if ! node.has_key?('redis')
    node.override[:redis][:installed] = "false"
end