VMNAME = "idoit"
HOSTNAME = "idoit"
DEFAULT_PASSWORD = "Admin123#"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, ip: "10.3.1.4"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
    v.name = VMNAME
  end

  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.provision :shell, path: "idoit/install.sh", :args => "'" + DEFAULT_PASSWORD + "'"

end