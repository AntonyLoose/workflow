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
read -p "Username: " name

useradd -m -G wheel -s /bin/bash "$name"
echo "Set password for $name:"
passwd "$name"

echo ""
echo "---------- Copying SSH keys ----------"
mkdir -p /home/"$name"/.ssh
cp /root/.ssh/github /home/"$name"/.ssh/
cp /root/.ssh/github.pub /home/"$name"/.ssh/
chown -R "$name":"$name" /home/"$name"/.ssh
chmod 700 /home/"$name"/.ssh
chmod 600 /home/"$name"/.ssh/github /home/"$name"/.ssh/github.pub

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
echo "---------- Installing sudo ----------"
pacman -Sy --noconfirm sudo

echo ""
echo "---------- Installing base packages ----------"
pacman -Sy --noconfirm \
  less nodejs npm neovim lua-language-server texlab xclip \
  i3-wm i3status picom kitty fastfetch firefox

echo ""
echo "---------- Setting up user environment ----------"

run_as_user() {
  sudo -u "$name" bash -c "$1"
}

# Clone user config repos as the new user
run_as_user "git clone git@github.com:AntonyLoose/nvim-config.git /home/$name/.config/nvim"
run_as_user "git clone git@github.com:AntonyLoose/i3-config.git /home/$name/.config/i3"
run_as_user "git clone git@github.com:AntonyLoose/i3status-config.git /home/$name/.config/i3status"
run_as_user "git clone git@github.com:AntonyLoose/picom-config.git /home/$name/.config/picom"
run_as_user "git clone git@github.com:AntonyLoose/kitty-config.git /home/$name/.config/kitty"
run_as_user "git clone git@github.com:AntonyLoose/dotfiles.git /home/$name/dotfiles"

# Fix ownership
chown -R "$name":"$name" /home/"$name"/.config /home/"$name"/dotfiles

# Setup dotfiles symlinks
run_as_user "rm -f /home/$name/.bashrc /home/$name/.bash_profile"
run_as_user "ln -s /home/$name/dotfiles/.bashrc /home/$name/.bashrc"
run_as_user "ln -s /home/$name/dotfiles/.bash_profile /home/$name/.bash_profile"
run_as_user "chown -h $name:$name /home/$name/.bashrc /home/$name/.bash_profile"

# Setup GTK dark theme preference
run_as_user "mkdir -p /home/$name/.config/gtk-3.0"
run_as_user "echo '[Settings]' > /home/$name/.config/gtk-3.0/settings.ini"
run_as_user "echo 'gtk-application-prefer-dark-theme=true' >> /home/$name/.config/gtk-3.0/settings.ini"

echo ""
echo "----- Installing additional language servers and npm packages -----"
pacman -Sy --noconfirm lua-language-server texlab
run_as_user "npm install -g typescript typescript-language-server vscode-langservers-extracted css-variables-language-server bash-language-server"

echo ""
echo "----- Done! User $name is set up with your configs and packages -----"
