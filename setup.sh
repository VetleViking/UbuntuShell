#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update before running
STATIC_IP="enter ip here"
SUBNET_MASK="enter subnet mask here"

# probably don't need to change these
INTERFACE="eth0"
GATEWAY="192.168.1.1"
DNS1="8.8.8.8"
DNS2="8.8.4.4"

NETPLAN_CONFIG="/etc/netplan/01-netcfg.yaml"
BACKUP_CONFIG="/etc/netplan/01-netcfg.yaml.bak"

if [ -f "$NETPLAN_CONFIG" ]; then
  echo "Backing up current netplan configuration to $BACKUP_CONFIG"
  cp $NETPLAN_CONFIG $BACKUP_CONFIG
else
  echo "No existing netplan configuration found, creating new configuration"
fi

echo "Writing new netplan configuration"

cat <<EOL > $NETPLAN_CONFIG
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      addresses:
        - $STATIC_IP/$SUBNET_MASK
      routes:
        - to: default
        via: $GATEWAY
      nameservers:
        search: []
        addresses:
          - $DNS1
          - $DNS2
EOL

echo "Applying new netplan configuration"
netplan apply

echo "Static IP configuration complete"