# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "f27-demo"

  config.vm.provider "parallels" do |p|
    p.linked_clone = false
    p.update_guest_tools = false
    p.memory = 1536
    p.cpus = 1
  end

  config.vm.define 'router' do |router|
    router.vm.provider "parallels" do |p|
      p.name = 'router'
    end

    router.vm.provision :ansible do |ansible|
      ansible.compatibility_mode='2.0'
      ansible.playbook = 'ansible/router.yaml'
      ansible.tags = ENV['ANSIBLE_TAGS']
    end

    router.vm.network "forwarded_port", host: 9001, guest: 9001
  end

  KUBERNETES_VERSION = ENV['KUBERNETES_VERSION'] || '1.9.6'
  clusters = [1,2,3,4]

  clusters.each do |id|
    config.vm.define "cluster#{id}" do |cluster|
      cluster.vm.provider "parallels" do |p|
        p.name = "cluster#{id}"
      end

      cluster.vm.network "forwarded_port", host: 8000 + id, guest: 9001

      cluster.vm.provision :ansible do |ansible|
        ansible.compatibility_mode='2.0'
        ansible.playbook = 'ansible/cluster.yaml'
        ansible.tags = ENV['ANSIBLE_TAGS']
        ansible.extra_vars = {
          kubernetes_version: KUBERNETES_VERSION
        }
      end
    end
  end
end
