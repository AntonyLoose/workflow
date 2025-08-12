#!/bin/bash

sudo pacman -Sy openssh xorg-xauth

read -rp "Enter your email: " email
read -rp "File path to save ssh key: " name

ssh-keygen -t rsa -b 4096 -C "$email" -f "$name"

echo "Copy the following public key and add it to the remote."

cat "$name.pub"

