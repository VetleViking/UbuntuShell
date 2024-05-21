#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update before running
STATIC_IP="enter ip here"
GATEWAY="enter gateway here"
SUBNET_MASK="enter subnet mask here"

# probably don't need to change these
INTERFACE="eth0"
DNS1="8.8.8.8"
DNS2="8.8.4.4"

NETPLAN_CONFIG="/etc/netplan/50-cloud-init.yaml"
BACKUP_CONFIG="/etc/netplan/50-cloud-init.yaml.bak"

if [ -f "$NETPLAN_CONFIG" ]; then
  echo "Backing up current netplan configuration to $BACKUP_CONFIG"
  cp $NETPLAN_CONFIG $BACKUP_CONFIG
else
  echo "No existing netplan configuration found, creating new configuration"
fi

echo "Writing new netplan configuration"

cat <<EOL > $NETPLAN_CONFIG
network:
    ethernets:
        eth0:
          addresses:
             - $STATIC_IP/$SUBNET_MASK
          nameservers:
            addresses: [4.2.2.2, 8.8.8.8]
          routes:
            - to: default
              via: $GATEWAY

          dhcp4: true
    version: 2
EOL

echo "Applying new netplan configuration"
netplan apply

echo "Static IP configuration complete"