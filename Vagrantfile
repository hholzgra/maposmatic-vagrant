# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# CONFIGURATION SETTINGS
#

# VM box to start from
BASE_BOX='debian/bookworm64'

# VM name
VM_NAME='maposmatic'

# how much of the hosts CPU and RAM resources to use
CPU_RATIO=1   # 100% of the CPU cores
MEM_RATIO=0.5 #  50% of the total RAM

# different branches of the ocitysmap renderer and 
# maposmatic web frontend can be used for testing
OCITYSMAP_BRANCH='master'
MAPOSMATIC_BRANCH='main'

# what host ports to map the maposmatic and weblate
# http services to
MAPOSMATIC_HOST_PORT=8000
WEBLATE_HOST_PORT=8080

#
# NO EDITING USUALLY NEEDED BEYOND THIS POINT
#

Vagrant.configure(2) do |config|
  host_os = RbConfig::CONFIG['host_os']
  if host_os =~ /darwin/
    host_cpus = `sysctl -n hw.ncpu`.to_i
    host_mem = `sysctl -n hw.memsize`.to_i / 1024^2
  elsif host_os =~ /linux/
    host_cpus = `nproc`.to_i
    host_mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024
  else # should be some sort of windows then?
    # TODO: should properly detect windows by name
    # TODO: should support other Unixoids like Solaris and the *BSDs, too
    host_cpus = `wmic cpu get NumberOfCores`.split("\n")[2].to_i
    host_mem = `wmic OS get TotalVisibleMemorySize`.split("\n")[2].to_i / 1024
  end

  use_cpus = (host_cpus * CPU_RATIO).ceil
  use_mem  = (host_mem  * MEM_RATIO).ceil

  puts "Running on #{host_os}, using #{use_cpus} of #{host_cpus} CPU cores and #{use_mem} of #{host_mem}MB RAM"

  config.vm.box = BASE_BOX

  config.vm.network "forwarded_port", guest: 80, host: MAPOSMATIC_HOST_PORT
  config.vm.network "forwarded_port", guest: 8080, host: WEBLATE_HOST_PORT

  config.vbguest.auto_update = false

  config.vm.boot_timeout = 600
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vb, override|
    # vb.gui = true
    vb.name   = VM_NAME
    vb.memory = use_mem
    vb.cpus   = use_cpus

    override.vm.synced_folder ".", "/vagrant/", mount_options: ["dmode=777"]
    override.vm.synced_folder "test", "/vagrant/test", mount_options: ["dmode=777"]
  end

  config.vm.provider "hyperv" do |h, override|
    override.vm.synced_folder ".", "/vagrant/", mount_options: ["dir_mode=777"]
    override.vm.synced_folder "test", "/vagrant/test", mount_options: ["dir_mode=777"]
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      owner: "_apt"
    }
  end

  unless Vagrant.has_plugin?("vagrant-vbguest")
    raise 'vbguest plugin is not installed - run "vagrant plugin install vagrant-vbguest" first'
  end

  unless Vagrant.has_plugin?("vagrant-disksize")
    raise 'disksize plugin is not installed - run "vagrant plugin install vagrant-disksize" first'
  end
  config.disksize.size = '2000GB'

  if Vagrant.has_plugin?("vagrant-env")
    config.env.enable
  end

  config.ssh.forward_x11 = true

  config.vm.provision "shell",
    env: {
      "GIT_AUTHOR_NAME":   ENV['GIT_AUTHOR_NAME'],
      "GIT_AUTHOR_EMAIL":  ENV['GIT_AUTHOR_EMAIL'],
      "MAPOSMATIC_BRANCH": MAPOSMATIC_BRANCH,
      "OCITYSMAP_BRANCH":  OCITYSMAP_BRANCH,
    },
    path: "provision.sh"

end
