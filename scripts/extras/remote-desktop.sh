#!/bin/bash

# Important: this script enables SSH, and thus should only be run on the remote.

sudo pacman -Sy openssh xorg-xauth
sudo systemctl enable --now sshd

