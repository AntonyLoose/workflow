#!/bin/bash

sudo pacman -Sy openssh xorg-xauth

read -rp "Enter your email: " email
read -rp "File path to save ssh key: " name

ssh-keygen -t rsa -b 4096 -C "$email" -f "$HOME/.ssh/$name"

echo "Copy the following public key and add it to the remote."

cat "$HOME/.ssh/$name.pub"

