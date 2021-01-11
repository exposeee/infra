# This guide is optimized for Vagrant 1.8 and above.
# Older versions of Vagrant put less info in the inventory they generate.
Vagrant.require_version ">= 1.8.0"
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Ensure we use our vagrant private key
  config.ssh.insert_key = false
  config.ssh.private_key_path = '~/.vagrant.d/insecure_private_key'

  # config.vm.box = "ubuntu/focal64"
  #
  # config.vm.provision "ansible" do |ansible|
  #   ansible.verbose = "v"
  #   ansible.playbook = "api-role.yml"
  # end
  config.vm.define 'exposeee-api' do |machine|
    machine.vm.box = 'ubuntu/focal64'

    machine.vm.network :private_network, ip: '192.168.88.22'
    machine.vm.hostname = 'api.local'
    machine.vm.synced_folder '.', '/vagrant', disabled: true

    machine.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "api-role.yml"
      ansible.become = true
      ansible.inventory_path = 'api-inventory-local'
      ansible.host_key_checking = false
    end
  end
end
