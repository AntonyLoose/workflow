#!/bin/bash

sudo pacman -Sy openssh xorg-xauth
yay -Sy rdesktop

# Connect to a remote desktop (running an RDP server) with the following command:
# rdesktop -g 1440x900 -P -z -x l -r sound:off -u <username> <ip>:3389
# more info here: https://wiki.archlinux.org/title/Rdesktop

read -rp "Enter your email: " email
read -rp "File path to save ssh key: " name

ssh-keygen -t rsa -b 4096 -C "$email" -f "$HOME/.ssh/$name"

echo "Copy the following public key and add it to the remote."

cat "$HOME/.ssh/$name.pub"

