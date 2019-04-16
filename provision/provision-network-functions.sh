#!/bin/bash
#
# provision-network-functions.sh
#
# This file is for common network helper functions that get called in
# other provisioners

network_detection() {
  # Network Detection
  #
  # Make an HTTP request to ppa.launchpad.net to determine if outside access is available
  # to us. If 3 attempts with a timeout of 5 seconds are not successful, then we'll
  # skip a few things further in provisioning rather than create a bunch of errors.
  if [[ "$(wget --tries=3 --timeout=10 --spider --recursive --level=2 https://ppa.launchpad.net 2>&1 | grep 'connected')" ]]; then
    echo "Succesful Network connection to ppa.launchpad.net detected..."
    ping_result="Connected"
  else
    echo "Network connection not detected. Unable to reach ppa.launchpad.net..."
    ping_result="Not Connected"
  fi
}

network_check() {
  network_detection
  if [[ ! "$ping_result" == "Connected" ]]; then
    echo " "
    echo "#################################################################"
    echo " "
    echo "Problem:"
    echo " "
    echo "Provisioning needs a network connection but none was found."
    echo "We tried to ping ppa.launchpad.net, and got no response."
    echo " "
    echo "Make sure you have a working internet connection, that you "
    echo "restarted after installing VirtualBox and Vagrant, and that "
    echo "they aren't blocked by a firewall or security software. If"
    echo "you can load https://ppa.launchpad.net in your browser, then we"
    echo "should be able to connect."
    echo " "
    echo "there may also be issues when combined"
    echo "with VPNs, disable your VPN and reprovision to see if this is"
    echo "the cause."
    echo " "
    echo "Network ifconfig output:"
    echo " "
    ifconfig
    echo " "
    echo "No network connection available, aborting provision. Try "
    echo "provisioning again once network connectivity is restored."
    echo "vagrant reload --provision"
    echo " "
    echo "#################################################################"

    exit 1
  fi
}


