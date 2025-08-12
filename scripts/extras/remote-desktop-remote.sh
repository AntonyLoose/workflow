#!/bin/bash

# Make sure to add the following to /etc/ssh/sshd_config:
# PasswordAuthentication no
# PermitRootLogin no
# X11Forwarding yes
# X11DisplayOffset 10
# X11UseLocalhost yes

sudo pacman -Sy openssh xorg-xauth
sudo systemctl enable --now sshd

read -rp "Enter the public key generated on the client: " key

if [ ! -f ~/.ssh/authorized_keys ]; then 
    touch ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    echo "Created ~/.ssh/authorized_keys"
fi

echo "$key" >> ~/.ssh/authorized_keys

