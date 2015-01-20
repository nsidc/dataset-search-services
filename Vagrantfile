# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # config.vm.network "forwarded_port", guest: 443, host: 8443

  # Sync the stuff to APP_PATH instead of /vagrant
  require_relative './config/app_config'
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', AppConfig::APP_PATH

  config.vm.provision :nsidc_puppet
end
