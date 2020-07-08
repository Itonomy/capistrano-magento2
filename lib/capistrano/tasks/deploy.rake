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

  # If both 'scopes' and 'themes' are available in app/etc/config.php then the build should not require database or
  # cache backend configuration to deploy. Removing the link to app/etc/env.php in this case prevents any possible
  # side effects that may arise from the build running in parallel to the live production release (such as the cache
  # being randomly disabled during the composer install step of the build, something which has been observed). This
  # requires "bin/magento scopes themes i18n" be run to dump theme/store config and the result comitted to repository
  before 'deploy:symlink:linked_files', :detect_scd_config do
    on primary fetch(:magento_deploy_setup_role) do
      unless test %Q[#{SSHKit.config.command_map[:php]} -r '
            $cfg = include "#{release_path}/app/etc/config.php";
            exit((int)(isset($cfg["scopes"]) && isset($cfg["themes"])));
        ']
        info "Removing app/etc/env.php from :linked_dirs for zero-side-effect pipeline deployment."
        remove :linked_files, 'app/etc/env.php'
      end
    end
  end

  before :starting, :confirm_action do
    if fetch(:magento_deploy_confirm).include? fetch(:stage).to_s
      print "\e[0;31m      Are you sure you want to deploy to #{fetch(:stage).to_s}? [y/n] \e[0m"
      proceed = STDIN.gets[0..0] rescue nil
      exit unless proceed == 'y' || proceed == 'Y'
    end
  end

  # Links app/etc/env.php if previously dropped from :linked_dirs in :detect_scd_config
  task 'symlink:link_env_php' do
    on release_roles :all do
      # Normally this would be wrapped in a conditional, but during SCD and/or DI compile Magento frequently writes
      # to cache_types -> compiled_config resulting in an env.php file being present (albeit the wrong one)
      execute :ln, "-fsn #{shared_path}/app/etc/env.php #{release_path}/app/etc/env.php"
    end
  end

  task :updated do
    invoke 'magento:deploy:verify'
    invoke 'magento:composer:install' if fetch(:magento_deploy_composer)
    invoke 'magento:setup:permissions'
    invoke 'magento:setup:db:config'
    invoke 'magento:magedbm:download' if (fetch(:magedbm_get_backup) || fetch(:magedbm_put_backup) || fetch(:magedbm_export_data) || fetch(:magedbm_import_data))

    if fetch(:magento_deploy_production)
      invoke 'magento:setup:static-content:deploy'
      invoke 'magento:advanced-bundling:deploy' if fetch(:magento_deploy_advanced_bundling)
      invoke 'magento:setup:di:compile'
      invoke 'magento:composer:dump-autoload' if fetch(:magento_deploy_composer)
    end

    invoke 'magento:pearl:compile' if fetch(:magento_deploy_pearl)

    invoke 'deploy:symlink:link_env_php'

    if fetch(:magento_deploy_production)
      invoke 'magento:deploy:mode:production'
    end

    invoke! 'magento:setup:permissions'
    invoke 'magento:maintenance:check'
    invoke 'magento:maintenance:enable' if fetch(:magento_deploy_maintenance)

    on release_roles :all do
      if test "[ -f #{current_path}/bin/magento ]"
        within current_path do
          execute :magento, 'maintenance:enable' if fetch(:magento_deploy_maintenance)
        end
      end
    end

    if not fetch(:magento_internal_zero_down_flag)
      on cache_hosts do
        within release_path do
          execute :magento, 'cache:flush'
        end
      end
      invoke 'magento:app:config:import'

      invoke 'magento:magedbm:put' if fetch(:magedbm_put_backup)
      invoke 'magento:magedbm:get' if fetch(:magedbm_get_backup)
      invoke 'magento:magedbm:import' if fetch(:magedbm_import_data)
      invoke 'magento:magedbm:export' if fetch(:magedbm_export_data)

      invoke 'magento:backups:db' if fetch(:magento_deploy_backup)

      invoke 'magento:setup:db:schema:upgrade'
      invoke 'magento:setup:db:data:upgrade'
    end

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
    invoke 'magento:cache:flush'
    invoke 'magento:maintenance:disable' if fetch(:magento_deploy_maintenance)
    invoke 'magento:cache:opcache:clear' if fetch(:magento_deploy_clear_opcache)
    invoke 'magento:cache:varnish:ban' if fetch(:magento_deploy_clear_varnish)
    invoke 'magento:backups:gzip' if fetch(:magento_deploy_backup)
  end
end
