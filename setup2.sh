#!/bin/bash

USER_NAME="$1"
PUB_KEY="$2"

if [ -z "$USER_NAME" ] || [ -z "$PUB_KEY" ]; then
    echo "Bruk: $0 <brukernavn> <offentlig nøkkel>"
    exit 1
fi

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
sed -i 's/^#PasswordAuthentication no/PasswordAuthentication no/' "$SSHD_CONFIG"

systemctl restart sshd

echo "SSH configuration complete for $USER_NAME"

exit 0