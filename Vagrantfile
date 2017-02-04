vmname = "idoit-dev"
hostname = "idoit-dev"
#mysql_root_password = "Admin123#"
#idoit_admin_password = "Admin123#"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = hostname
  config.vm.network :private_network, ip: "10.3.1.4"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
    v.name = vmname
  end

  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.provision :shell, path: "idoit/install.sh"

end
