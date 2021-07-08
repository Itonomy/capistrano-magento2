##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

include Capistrano::Magento2::Helpers

namespace :deploy do
  before 'deploy:check:linked_files', 'magento:deploy:check'
  before 'deploy:symlink:linked_files', 'magento:deploy:local_config'

  before :starting, :confirm_action do
    if fetch(:magento_deploy_confirm).include? fetch(:stage).to_s
      print "\e[0;31m      Are you sure you want to deploy to #{fetch(:stage).to_s}? [y/n] \e[0m"
      proceed = STDIN.gets[0..0] rescue nil
      exit unless proceed == 'y' || proceed == 'Y'
    end
  end

  task :updated do
    invoke 'magento:deploy:verify'
    invoke 'magento:composer:install' if fetch(:magento_deploy_composer)
    invoke 'magento:setup:permissions'
    invoke 'magento:setup:db:config'

    invoke 'magento:magedbm:download' if (fetch(:magedbm_get_backup) || fetch(:magedbm_put_backup) || fetch(:magedbm_export_data) || fetch(:magedbm_import_data))

    if fetch(:magento_deploy_production)
      invoke 'yarn:install' if fetch(:magento_deploy_yarn)
      invoke 'yarn:build' if fetch(:magento_deploy_yarn)
      invoke 'magento:setup:static-content:deploy'
      invoke 'magento:advanced-bundling:deploy' if fetch(:magento_deploy_advanced_bundling)
      invoke 'magento:setup:di:compile'
    end

    invoke 'magento:pearl:compile' if fetch(:magento_deploy_pearl)

    invoke 'magento:setup:permissions'
    invoke 'magento:maintenance:enable' if fetch(:magento_deploy_maintenance)

    invoke 'magento:magedbm:put' if fetch(:magedbm_put_backup)
    invoke 'magento:magedbm:get' if fetch(:magedbm_get_backup)
    invoke 'magento:magedbm:import' if fetch(:magedbm_import_data)
    invoke 'magento:magedbm:export' if fetch(:magedbm_export_data)
    invoke 'magento:backups:db' if fetch(:magento_deploy_backup)
    invoke 'magento:setup:upgrade'
    invoke 'magento:setup:db:schema:upgrade'
    invoke 'magento:setup:db:data:upgrade'

    on primary fetch(:magento_deploy_setup_role) do
      within release_path do
        _disabled_modules = disabled_modules
        if _disabled_modules.count > 0
          info "\nThe following modules are disabled per app/etc/config.php:\n"
          _disabled_modules.each do |module_name|
            info '- ' + module_name
          end
        end
      end
    end
  end

  task :published do
    invoke 'magento:magepack-advanced-bundling:disable' if fetch(:magepack_advanced_bundling)
    invoke 'magento:magepack-advanced-bundling:generate' if fetch(:magepack_advanced_bundling)
    invoke 'magento:magepack-advanced-bundling:bundle' if fetch(:magepack_advanced_bundling)
    invoke 'magento:magepack-advanced-bundling:enable' if fetch(:magepack_advanced_bundling)
    invoke 'magento:cache:flush'
    invoke 'magento:maintenance:disable' if fetch(:magento_deploy_maintenance)
    invoke 'magento:cache:opcache:clear' if fetch(:magento_deploy_clear_opcache)
    invoke 'magento:cache:varnish:ban' if fetch(:magento_deploy_clear_varnish)
    invoke 'magento:backups:gzip' if fetch(:magento_deploy_backup)
  end
end
