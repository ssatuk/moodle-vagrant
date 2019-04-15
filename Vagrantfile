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

end