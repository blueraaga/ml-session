########################################################################
# Vagrant config file for ML Workbench
########################################################################

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"
  # Increase timeout from (the default value of) 300 seconds to let
  # the machine boot
  config.vm.boot_timeout = 600
  config.vm.define "MLSE" do |foohost|
end
  config.vm.provider :virtualbox do |vb|
    vb.name = "MLSE"

    # Redirect serial comm to file to speed up booting
    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    vb.customize ["modifyvm", :id, "--uartmode1", "file", "./ttyS0.log"]

    # Customize the amount of memory on the VM:
    vb.memory = "8192"

  end
  
  # Dont check for VB Guest Additions
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false  
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  # Zeppelin Notebooks
  config.vm.network "forwarded_port", guest: 8080, host: 8181
  #  Jupyter Notebook
  config.vm.network "forwarded_port", guest: 8888, host: 8787

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", path: "bootstrap/core.sh"
  config.vm.provision "shell", path: "bootstrap/booster.sh"
end
