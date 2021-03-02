# This guide is optimized for Vagrant 1.8 and above.
# Older versions of Vagrant put less info in the inventory they generate.
Vagrant.require_version ">= 1.8.0"
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Ensure we use our vagrant private key
  config.ssh.insert_key = false
  config.ssh.private_key_path = '~/.vagrant.d/insecure_private_key'

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 4096
    vb.cpus = 2
  end

  config.vm.define 'exposeee-app' do |app|
    app.vm.box = 'ubuntu/focal64'

    app.vm.network :private_network, ip: '192.168.88.23'
    app.vm.hostname = 'app.local'
    app.vm.synced_folder '.', '/vagrant', disabled: true

    app.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "app-role.yml"
      ansible.become = true
      ansible.inventory_path = 'app-inventory-local'
      ansible.host_key_checking = false
    end
  end

  config.vm.define 'exposeee-api' do |api|
    api.vm.box = 'ubuntu/focal64'

    api.vm.network :private_network, ip: '192.168.88.22'
    api.vm.hostname = 'api.local'
    api.vm.synced_folder '.', '/vagrant', disabled: true

    api.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "api-role.yml"
      ansible.become = true
      ansible.inventory_path = 'api-inventory-local'
      ansible.host_key_checking = false
    end
  end

  config.vm.define 'exposeee-db' do |db|
    db.vm.box = 'ubuntu/focal64'

    db.vm.network :private_network, ip: '192.168.88.21'
    db.vm.network :forwarded_port, guest: 5432, host: 5432
    db.vm.hostname = 'db.local'
    db.vm.synced_folder '.', '/vagrant', disabled: true

    db.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "db-role.yml"
      ansible.become = true
      ansible.inventory_path = 'db-inventory-local'
      ansible.host_key_checking = false
    end
  end
end
