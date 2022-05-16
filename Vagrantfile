Vagrant.configure("2") do |config|

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  config.vm.define :clienteCentOS2 do |clienteCentOS2|
    clienteCentOS2.vm.box = "bento/centos-7.9"
    clienteCentOS2.vm.network :private_network, ip: "192.168.50.6"
    clienteCentOS2.vm.hostname = "clienteCentOS2"
    config.vm.synced_folder ".", "/vagrant/JuanFelipe"
    end

  config.vm.define :masterSQL do |masterSQL|
    masterSQL.vm.box = "bento/centos-7.9"
    masterSQL.vm.network :private_network, ip: "192.168.50.7"
    masterSQL.vm.hostname = "masterSQL"
    config.vm.synced_folder ".", "/vagrant/JuanFelipe"
    end

  config.vm.define :slaveSQL do |slaveSQL|
    slaveSQL.vm.box = "bento/centos-7.9"
    slaveSQL.vm.network :private_network, ip: "192.168.50.4"
    slaveSQL.vm.hostname = "slaveSQL"
    config.vm.synced_folder ".", "/vagrant/JuanFelipe"
    end
        
  config.vm.define :maxscale do |maxscale|
    maxscale.vm.box = "bento/centos-7.9"
    maxscale.vm.network :private_network, ip: "192.168.50.5"
    maxscale.vm.hostname = "maxscale"
    config.vm.synced_folder ".", "/vagrant/JuanFelipe"
    end
  end

