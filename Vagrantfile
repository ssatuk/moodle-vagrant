# -*- mode: ruby -*-
# vi: set ft=ruby ts=2 sw=2 et:
Vagrant.require_version ">= 2.1.4"
require 'yaml'
require 'fileutils'

vagrant_dir = File.expand_path(File.dirname(__FILE__))
show_logo = false
branch_c = "\033[38;5;6m"#111m"
red="\033[38;5;9m"#124m"
green="\033[1;38;5;2m"#22m"
blue="\033[38;5;4m"#33m"
purple="\033[38;5;5m"#129m"
docs="\033[0m"
yellow="\033[38;5;3m"#136m"
yellow_underlined="\033[4;38;5;3m"#136m"
url=yellow_underlined
creset="\033[0m"

if File.file?(File.join(vagrant_dir, 'moodle-custom.yml')) == false then
    puts "#{yellow}Copying #{red}moodle-config.yml#{yellow} to #{green}moodle-custom.yml#{yellow}\nIMPORTANT NOTE: Make all modifications to #{green}moodle-custom.yml#{yellow} in future so that they are not lost when moodle updates.#{creset}\n\n"
    FileUtils.cp( File.join(vagrant_dir, 'moodle-config.yml'), File.join(vagrant_dir, 'moodle-custom.yml') )
  end
  
  moodle_config_file = File.join(vagrant_dir, 'moodle-custom.yml')
  
  moodle_config = YAML.load_file(moodle_config_file)
  
  if ! moodle_config['sites'].kind_of? Hash then
    moodle_config['sites'] = Hash.new
  end
  
  if ! moodle_config['hosts'].kind_of? Hash then
    moodle_config['hosts'] = Array.new
  end
  
  moodle_config['hosts'] += ['moodle.test'] 
  moodle_config['hosts'] += ['core-moodle.test']
  moodle_config['hosts'] += ['webgrind.test']

  

  if ! moodle_config['utility-sources'].kind_of? Hash then
    moodle_config['utility-sources'] = Hash.new
  else
    moodle_config['utility-sources'].each do |name, args|
      if args.kind_of? String then
          repo = args
          args = Hash.new
          args['repo'] = repo
          args['branch'] = 'master'
  
          moodle_config['utility-sources'][name] = args
      end
    end
  end

  # for now default to core utilities from VVV project (our inspiration)
  if ! moodle_config['utility-sources'].key?('core')
    moodle_config['utility-sources']['core'] = Hash.new
    moodle_config['utility-sources']['core']['repo'] = 'https://github.com/Varying-Vagrant-Vagrants/vvv-utilities.git'
    moodle_config['utility-sources']['core']['branch'] = 'master'
  end
  
  if ! moodle_config['utilities'].kind_of? Hash then
    moodle_config['utilities'] = Hash.new
  end

  if ! moodle_config['vm_config'].kind_of? Hash then
    moodle_config['vm_config'] = Hash.new
  end
  
  defaults = Hash.new
  defaults['memory'] = 2048
  defaults['cores'] = 1
  # This should rarely be overridden, so it's not included in the default moodle-config.yml file.
  defaults['private_network_ip'] = '192.168.50.4'
  
  moodle_config['vm_config'] = defaults.merge(moodle_config['vm_config'])
  
  if defined? moodle_config['vm_config']['provider'] then
    # Override or set the vagrant provider.
    ENV['VAGRANT_DEFAULT_PROVIDER'] = moodle_config['vm_config']['provider']
  end
  

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # we will try to autodetect this path. 
  # However, if we cannot or you have a special one you may pass it like:
  # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
  # or an URL:
  # config.vbguest.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"
  # or relative to the Vagrantfile:
  config.vbguest.iso_path = "../vbox/VBoxGuestAdditions.iso"
  
  # set auto_update to false, if you do NOT want to check the correct 
  # additions version when booting this machine
  config.vbguest.auto_update = false
  
  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true

  # SSH Agent Forwarding
  #
  # Enable agent forwarding on vagrant ssh commands. This allows you to use ssh keys
  # on your host machine inside the guest. See the manual for `ssh-add`.
  config.ssh.forward_agent = true

  # SSH Key Insertion
  #
  # This is disabled
  config.ssh.insert_key = false

  # latest Ubuntu 16.04
  config.vm.box = "ubuntu/xenial64"

  # Store the current version of Vagrant for use in conditionals when dealing
  # with possible backward compatible issues.
  vagrant_version = Vagrant::VERSION.sub(/^v/, '')

  # Configurations from 1.0.x can be placed in Vagrant 1.1.x specs like the following.
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", moodle_config['vm_config']['memory']]
    v.customize ["modifyvm", :id, "--cpus", moodle_config['vm_config']['cores']]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # see https://github.com/hashicorp/vagrant/issues/7648
    v.customize ['modifyvm', :id, '--cableconnected1', 'on']

    v.customize ["modifyvm", :id, "--rtcuseutc", "on"]
    v.customize ["modifyvm", :id, "--audio", "none"]
    v.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate//srv/www", "1"]
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate//srv/config", "1"]

    # Set the box name in VirtualBox to match the working directory.
    moodle_pwd = Dir.pwd
    v.name = File.basename(vagrant_dir) + "_" + (Digest::SHA256.hexdigest vagrant_dir)[0..10]
  end



  # Local Machine Hosts
  #
  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may need to
  # enter a password for Vagrant to access your hosts file.
  #
  # By default, we'll include the domains set up by through the moodle-hosts file
  # located in the www/ directory and in moodle-config.yml.
  if defined?(VagrantPlugins::HostsUpdater)
    # Pass the found host names to the hostsupdater plugin so it can perform magic.
    config.hostsupdater.aliases = moodle_config['hosts']
    config.hostsupdater.remove_on_suspend = true
  end

  # Private Network (default)
  #
  # A private network is created by default. This is the IP address through which your
  # host machine will communicate to the guest. In this default configuration, the virtual
  # machine will have an IP address of 192.168.50.4 and a virtual network adapter will be
  # created on your host machine with the IP of 192.168.50.1 as a gateway.
  #
  # Access to the guest machine is only available to your local host. To provide access to
  # other devices, a public network should be configured or port forwarding enabled.
  #
  # Note: If your existing network is using the 192.168.50.x subnet, this default IP address
  # should be changed. If more than one VM is running through VirtualBox, including other
  # Vagrant machines, different subnets should be used for each.
  #
  config.vm.network :private_network, id: "moodle_primary", ip: moodle_config['vm_config']['private_network_ip']

  # Public Network (disabled)
  #
  # Using a public network rather than the default private network configuration will allow
  # access to the guest machine from other devices on the network. By default, enabling this
  # line will cause the guest machine to use DHCP to determine its IP address. You will also
  # be prompted to choose a network interface to bridge with during `vagrant up`.
  #
  # config.vm.network :public_network

  # Port Forwarding (disabled)
  #
  # This network configuration works alongside any other network configuration in Vagrantfile
  # and forwards any requests to port 8080 on the local host machine to port 80 in the guest.
  #
  # Port forwarding is a first step to allowing access to outside networks, though additional
  # configuration will likely be necessary on our host machine or router so that outside
  # requests will be forwarded from 80 -> 8080 -> 80.
  #
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Drive mapping
  #
  # The following config.vm.synced_folder settings will map directories in your Vagrant
  # virtual machine to directories on your local machine. Once these are mapped, any
  # changes made to the files in these directories will affect both the local and virtual
  # machine versions. Think of it as two different ways to access the same file. When the
  # virtual machine is destroyed with `vagrant destroy`, your files will remain in your local
  # environment.

  # /srv/database/
  #
  # If a database directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is used to maintain default database scripts as well as backed
  # up MariaDB/MySQL dumps (SQL files) that are to be imported automatically on vagrant up
  config.vm.synced_folder "database/", "/srv/database"

  # If the mysql_upgrade_info file from a previous persistent database mapping is detected,
  # we'll continue to map that directory as /var/lib/mysql inside the virtual machine. Once
  # this file is changed or removed, this mapping will no longer occur. A db_backup command
  # is now available inside the virtual machine to backup all databases for future use. This
  # command is automatically issued on halt, suspend, and destroy
  if File.exists?(File.join(vagrant_dir,'database/data/mysql_upgrade_info')) then
    config.vm.synced_folder "database/data/", "/var/lib/mysql", :mount_options => [ "dmode=777", "fmode=777" ]

    # The Parallels Provider does not understand "dmode"/"fmode" in the "mount_options" as
    # those are specific to Virtualbox. The folder is therefore overridden with one that
    # uses corresponding Parallels mount options.
    config.vm.provider :parallels do |v, override|
      override.vm.synced_folder "database/data/", "/var/lib/mysql", :mount_options => []
    end
    # Neither does the HyperV provider
    config.vm.provider :hyperv do |v, override|
      override.vm.synced_folder "database/data/", "/var/lib/mysql", :mount_options => []
    end
  end

  # /srv/config/
  #
  # If a server-conf directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is currently used to maintain various config files for php and
  # nginx as well as any pre-existing database files.
  config.vm.synced_folder "config/", "/srv/config"

  # /var/log/
  #
  # If a log directory exists in the same directory as your Vagrantfile, a mapped
  # directory inside the VM will be created for some generated log files.
  config.vm.synced_folder "log/", "/var/log", :owner => "vagrant", :mount_options => [ "dmode=777", "fmode=777" ]

  # /srv/www/
  #
  # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
  # inside the VM will be created that acts as the default location for nginx sites. Put all
  # of your project files here that you want to access through the web server
  config.vm.synced_folder "www/", "/srv/www", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]

  #moodle_config['sites'].each do |site, args|
  #  if args['local_dir'] != File.join(vagrant_dir, 'www', site) then
  #    config.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
  #  end
  #end

  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Provisioning
  #
  # Process one or more provisioning scripts depending on the existence of custom files.
  #
  # provison-pre.sh acts as a pre-hook to our default provisioning script. Anything that
  # should run before the shell commands laid out in provision.sh (or your provision-custom.sh
  # file) should go in this script. If it does not exist, no extra provisioning will run.
  if File.exists?(File.join(vagrant_dir,'provision','provision-pre.sh')) then
    config.vm.provision "pre", type: "shell", path: File.join( "provision", "provision-pre.sh" )
  end

  # provision.sh or provision-custom.sh
  #
  # By default, Vagrantfile is set to use the provision.sh bash script located in the
  # provision directory. If it is detected that a provision-custom.sh script has been
  # created, that is run as a replacement. This is an opportunity to replace the entirety
  # of the provisioning provided by default.
  if File.exists?(File.join(vagrant_dir,'provision','provision-custom.sh')) then
    config.vm.provision "custom", type: "shell", path: File.join( "provision", "provision-custom.sh" )
  else
    config.vm.provision "default", type: "shell", path: File.join( "provision", "provision.sh" )
  end

end