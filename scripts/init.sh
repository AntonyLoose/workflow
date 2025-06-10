#!/bin/bash

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
useradd -m -G wheel "$name"

echo "Set password for $name:"
passwd "$name"


echo ""
echo "---------- Copying keys ----------"

mkdir /home/$name/.ssh
touch /home/$name/.ssh/github
touch /home/$name/.ssh/github.pub
cp /root/.ssh/github /home/$name/.ssh/github
cp /root/.ssh/github.pub /home/$name/.ssh/github.pub
chown -R $name:$name /home/$name/.ssh


echo "---------- Security ----------"
echo ""


echo "----- Firewalls -----"
echo ""

pacman -Sy --noconfirm ufw
systemctl enable --now ufw
ufw default deny incoming
ufw default allow outgoing


echo ""
echo "----- Failed login delay -----"
echo "auth optional pam_faildelay.so delay=4000000" >> /etc/pam.d/system-login


echo ""
echo "----- Disabling root access via SSH -----"

echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/20-deny-root.conf

echo ""
echo "---------- Installing sudo ----------"

pacman -Sy --noconfirm sudo

echo ""
echo "---------- Switching to user ----------"

su $name


echo ""
echo "---------- Enabling ssh agent ----------"
eval "$(ssh-agent -s)"
ssh-add /home/$name/.ssh/github


echo "---------- less ----------"
echo ""

sudo pacman -Sy --noconfirm less


echo "---------- npm & nodejs ----------"
echo ""

sudo pacman -Sy --noconfirm nodejs npm


echo ""

echo "---------- Neovim ----------"
sudo pacman -Sy --noconfirm neovim
rm -rf /home/"$name"/.config/nvim
git clone git@github.com:AntonyLoose/nvim-config.git /home/"$name"/.config/nvim
chown -R "$name:$name" /home/"$name"/.config/nvim


echo ""

echo "----- Language Servers -----"
sudo pacman -Sy --noconfirm lua-language-server texlab
npm install -g typescript typescript-language-server vscode-langservers-extracted css-variables-language-server bash-language-server


echo ""

echo "---------- i3 ----------"
sudo pacman -Sy --noconfirm i3-wm
rm -rf /home/"$name"/.config/i3
git clone git@github:AntonyLoose/i3-config /home/"$name"/.config/i3
chown -R "$name:$name" /home/"$name"/.config/i3

echo ""
echo "---------- i3status ----------"

sudo pacman -Sy --noconfirm i3status
rm -rf /home/"$name"/.config/i3status
git clone git@github:AntonyLoose/i3status-config /home/"$name"/.config/i3status
chown -R "$name:$name" /home/"$name"/.config/i3status


echo ""
echo "---------- picom ----------"

sudo pacman -Sy --noconfirm picom
rm -rf /home/"$name"/.config/picom
git clone git@github.com:AntonyLoose/picom-config /home/"$name"/.config/picom
chown -R "$name:$name" /home/"$name"/.config/picom


echo ""
echo "---------- Kitty ----------"

sudo pacman -Sy --noconfirm kitty
rm -rf /home/"$name"/.config/kitty
git clone git@github.com:AntonyLoose/kitty-config /home/"$name"/.config/kitty
chown -R "$name:$name" /home/"$name"/.config/kitty


echo ""
echo "---------- fastfetch ----------"

sudo pacman -Sy --noconfirm fastfetch


echo ""
echo "---------- Firefox ----------"

sudo pacman -Sy --noconfirm firefox


echo ""
echo "---------- Device theme ----------"

sudo touch ~/.config/gtk-3.0/settings.ini
"[Settings]" > ~/.config/gtk-3.0/settings.ini
"gtk-application-prefer-dark-theme=true" > ~/.config/gtk-3.0/settings.ini

echo ""
echo "---------- Owning .config ----------"
chown -R $name:$name ~/.config


echo ""
echo "----- Done -----"
