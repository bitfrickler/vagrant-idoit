$ProjectName = 'idoit-dev'

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "#{$ProjectName}"
  config.vm.network :private_network, ip: "10.3.1.4"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end

  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.provision :shell, path: "idoit/install.sh"

end
