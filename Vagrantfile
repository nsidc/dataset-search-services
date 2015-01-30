# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ["/puppet/modules/*", "/puppet/.tmp/*"]
  config.vm.provision :nsidc_puppet
end
