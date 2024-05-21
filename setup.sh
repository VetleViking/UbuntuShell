#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Check if part is given
if [ -z "$PART" ]; then
    echo "Usage: $0 <part>"
    echo "Part can be 'net', 'ssh', or 'both'"
    exit 1
fi

if [ "$PART" = "net" ] || [ "$PART" = "both" ]; then

  if ["$PART" = "net" ]; then
    STATIC_IP="$2"
    GATEWAY="$3"
    SUBNET_MASK="$4"
  else
    STATIC_IP="$4"
    GATEWAY="$5"
    SUBNET_MASK="$6"
  fi

  if [ -z "$STATIC_IP" ] || [ -z "$GATEWAY" ] || [ -z "$SUBNET_MASK" ] && [ "$PART" == "net"]; then
    echo "Usage: $0 net <static_ip> <gateway> <subnet_mask>"
    exit 1
  else if [ -z "$STATIC_IP" ] || [ -z "$GATEWAY" ] || [ -z "$SUBNET_MASK" ] && [ "$PART" == "both"]; then
    echo "Usage: $0 both <user_name> <pub_key> <static_ip> <gateway> <subnet_mask>"
    exit 1
  fi

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
EOL
fi

if [ "$PART" = "ssh" ] || [ "$PART" = "both" ]; then
  PART="$1"
  USER_NAME="$2"
  PUB_KEY="$3"

  HOME_DIR=$(eval echo ~$USER_NAME)
  SSH_DIR="$HOME_DIR/.ssh"
  AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

  if [ ! -d "$SSH_DIR" ]; then
      mkdir -p "$SSH_DIR"
      chown "$USER_NAME":"$USER_NAME" "$SSH_DIR"
      chmod 700 "$SSH_DIR"
  fi

  # add public key to authorized_keys
  echo "$PUB_KEY" >> "$AUTHORIZED_KEYS"
  chown "$USER_NAME":"$USER_NAME" "$AUTHORIZED_KEYS"
  chmod 600 "$AUTHORIZED_KEYS"

  # disable password authentication
  SSHD_CONFIG="/etc/ssh/sshd_config"
  cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"
  sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' "$SSHD_CONFIG"
  sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' "$SSHD_CONFIG"

  systemctl restart ssh
fi

if [ "$PART" = "net" ] || [ "$PART" == "both"]; then
  echo "Network configuration complete for $STATIC_IP"
fi

if [ "$PART" = "ssh" ] || [ "$PART" == "both"]; then
  echo "SSH configuration complete for $USER_NAME"
fi

exit 0