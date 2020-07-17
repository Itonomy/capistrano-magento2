##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

set :linked_files, fetch(:linked_files, []).push(
  'app/etc/env.php',
  'app/etc/config.local.php',
  'var/.setup_cronjob_status',
  'var/.update_cronjob_status'
)

set :linked_files_touch, fetch(:linked_files_touch, []).push(
  'app/etc/env.php',
  'app/etc/config.local.php',
  'var/.setup_cronjob_status',
  'var/.update_cronjob_status'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'pub/media',
  'pub/sitemaps',
  'var/backups', 
  'var/composer_home', 
  'var/importexport', 
  'var/import_history', 
  'var/log',
  'var/session', 
  'var/tmp'
)

# magento composer repository auth credentials
set :magento_auth_repo_name, fetch(:magento_auth_repo_name, 'http-basic.repo.magento.com')
set :magento_auth_public_key, fetch(:magento_auth_public_key, false)
set :magento_auth_private_key, fetch(:magento_auth_private_key, false)

# deploy permissions defaults
set :magento_deploy_chmod_d, fetch(:magento_deploy_chmod_d, '2770')
set :magento_deploy_chmod_f, fetch(:magento_deploy_chmod_f, '0660')
set :magento_deploy_chmod_x, fetch(:magento_deploy_chmod_x, ['bin/magento'])

# MageDB2 backups
set :magedbm_put_backup, fetch(:magedbm_put_backup, false)
set :magedbm_get_backup, fetch(:magedbm_get_backup, false)
set :magedbm_export_data, fetch(:magedbm_export_data, false)
set :magedbm_import_data, fetch(:magedbm_import_data, false)
set :magedbm_project_name, fetch(:magedbm_project_name, '')

# deploy configuration defaults
set :magento_deploy_composer, fetch(:magento_deploy_composer, true)
set :magento_deploy_backup, fetch(:magento_deploy_backup, true)
set :magento_deploy_confirm, fetch(:magento_deploy_confirm, [])
set :magento_deploy_languages, fetch(:magento_deploy_languages, ['en_US'])
set :magento_deploy_maintenance, fetch(:magento_deploy_maintenance, true)
set :magento_deploy_maintenance_allowed_ips, fetch(:magento_deploy_maintenance_allowed_ips, []);
set :magento_deploy_production, fetch(:magento_deploy_production, true)
set :magento_deploy_themes, fetch(:magento_deploy_themes, [])
set :magento_deploy_pearl, fetch(:magento_deploy_pearl, false)
set :magento_deploy_pearl_stores, fetch(:magento_deploy_pearl_stores, [])
set :magento_deploy_advanced_bundling, fetch(:magento_deploy_advanced_bundling, false)
set :magento_deploy_jobs, fetch(:magento_deploy_jobs, nil)      # this defaults to 4 when supported by bin/magento
set :magento_deploy_clear_opcache, fetch(:magento_deploy_clear_opcache, true)
set :magento_deploy_clear_opcache_additional_websites, fetch(:magento_deploy_clear_opcache_additional_websites, [])
set :magento_deploy_clear_varnish, fetch(:magento_deploy_clear_varnish, true)
set :composer_install_flags, fetch(:composer_install_flags, '--prefer-dist --no-interaction --no-progress --no-suggest')
set :rjs_executable_path, fetch(:rjs_executable_path, 'r.js')

# deploy magepack advanced bundling defaults
set :magepack_advanced_bundling, fetch(:magepack_advanced_bundling, false)
set :magepack_advanced_bundling_cms_url, fetch(:magepack_advanced_bundling_cms_url, '')
set :magepack_advanced_bundling_category_url, fetch(:magepack_advanced_bundling_category_url, '')
set :magepack_advanced_bundling_product_url, fetch(:magepack_advanced_bundling_product_url, '')

# deploy targetting defaults
set :magento_deploy_setup_role, fetch(:magento_deploy_setup_role, :all)
set :magento_deploy_cache_shared, fetch(:magento_deploy_cache_shared, true)

# pending deploy check defaults
set :magento_deploy_pending_role, fetch(:magento_deploy_pending_role, :all)
set :magento_deploy_pending_warn, fetch(:magento_deploy_pending_warn, true)
set :magento_deploy_pending_format, fetch(
  :magento_deploy_pending_format,
  '--pretty="format:%C(yellow)%h %Cblue%>(12)%ai %Cgreen%<(7)%aN%Cred%d %Creset%s"'
)