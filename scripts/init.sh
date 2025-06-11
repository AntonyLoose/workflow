#!/bin/bash

set -euo pipefail

echo "--------------- Initialising Arch Config ---------------"
echo ""

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

echo "---------- Verifying Git Install ----------"
echo ""

if ! command -v git >/dev/null 2>&1; then
  echo "Git is not installed. Please install Git and configure authentication before running this script."
  exit 1
fi

echo ""
echo "---------- Creating User ----------"
read -rp "Username: " name

useradd -m -G wheel -s /bin/bash "$name"
echo "Set password for $name:"
passwd "$name"

echo ""
echo "---------- Installing sudo ----------"
pacman -Sy --noconfirm sudo

echo ""
echo "---------- Copying SSH keys ----------"
install -d -m 700 -o "$name" -g "$name" "/home/$name/.ssh"
install -m 600 -o "$name" -g "$name" /root/.ssh/github "/home/$name/.ssh/github"
install -m 600 -o "$name" -g "$name" /root/.ssh/github.pub "/home/$name/.ssh/github.pub"

echo ""
echo "---------- Security ----------"

echo "----- Firewalls -----"
pacman -Sy --noconfirm ufw
ufw default deny incoming
ufw default allow outgoing
systemctl enable --now ufw
ufw enable

echo ""
echo "----- Failed login delay -----"
if ! grep -q "pam_faildelay.so" /etc/pam.d/system-login; then
  echo "auth optional pam_faildelay.so delay=4000000" >> /etc/pam.d/system-login
fi

echo ""
echo "----- Disabling root access via SSH -----"
echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/20-deny-root.conf

echo ""
echo "---------- Installing base packages ----------"
pacman -Sy --noconfirm \
  less nodejs npm neovim lua-language-server texlab xclip \
  i3-wm i3status picom kitty fastfetch firefox \
  networkmanager keychain base-devel dmenu feh \
  xorg xorg-server xorg-xinit pipewire pipewire-pulse \
  wireplumber pipewire-alsa

echo ""
echo "---------- Setting up user environment ----------"

run_as_user() {
  sudo -u "$name" -- bash -c "$1"
}

# Persist SSH keychain setup
run_as_user "echo 'eval \$(keychain --eval ~/.ssh/github)' >> ~/.bash_profile"

# Clone config repos as the new user
run_as_user "git clone git@github.com:AntonyLoose/nvim-config.git ~/.config/nvim"
run_as_user "git clone git@github.com:AntonyLoose/i3-config.git ~/.config/i3"
run_as_user "git clone git@github.com:AntonyLoose/i3status-config.git ~/.config/i3status"
run_as_user "git clone git@github.com:AntonyLoose/picom-config.git ~/.config/picom"
run_as_user "git clone git@github.com:AntonyLoose/kitty-config.git ~/.config/kitty"
run_as_user "git clone git@github.com:AntonyLoose/dotfiles.git ~/dotfiles"

# Fix ownership
chown -R "$name:$name" "/home/$name/.config" "/home/$name/dotfiles"

# Setup dotfiles symlinks
run_as_user "rm -f ~/.bashrc ~/.bash_profile"
run_as_user "ln -s ~/dotfiles/.bashrc ~/.bashrc"
run_as_user "ln -s ~/dotfiles/.bash_profile ~/.bash_profile"

# GTK dark theme
run_as_user "mkdir -p ~/.config/gtk-3.0 && echo -e '[Settings]\ngtk-application-prefer-dark-theme=true' > ~/.config/gtk-3.0/settings.ini"

# Set i3 to run on login
run_as_user "echo 'exec i3' > ~/.xinitrc"

# Enable pipewire user services
run_as_user "systemctl --user enable pipewire pipewire-pulse"

# Setup timezone
timedatectl set-ntp true
systemctl restart systemd-timesyncd
timedatectl set-timezone Australia/Melbourne

echo ""
echo "----- Installing npm language servers -----"
run_as_user "npm install -g typescript typescript-language-server vscode-langservers-extracted css-variables-language-server bash-language-server"

echo ""
echo "----- Done! User $name is set up with your configs and packages. -----"

echo ""
echo "----- Rebooting -----"
reboot
