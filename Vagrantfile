# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "f27"

  config.vm.provider "parallels" do |p|
    #p.name = File.basename(Dir.pwd)
    p.linked_clone = true
    #p.update_guest_tools = true
    p.memory = 2048
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
  end

  KUBERNETES_VERSION = ENV['KUBERNETES_VERSION'] || '1.9.6'
  clusters = [1,2,3,4]

  clusters.each do |id|
    config.vm.define "cluster#{id}" do |router|
      router.vm.provider "parallels" do |p|
        p.name = "cluster#{id}"
        p.memory = 1536
      end

      router.vm.provision :ansible do |ansible|
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