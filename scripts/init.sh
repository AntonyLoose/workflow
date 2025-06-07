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


echo "---------- Creating User ----------"
echo ""

read -p "Username: " name
useradd -m -G wheel "$name"

echo "Set password for $name:"
passwd "$name"


echo "---------- Security ----------"
echo ""


echo "----- Firewalls -----"
echo ""
pacman -Sy --noconfirm ufw
systemctl enable --now ufw
ufw default deny incoming
ufw default allow outgoing


echo "----- Failed login delay -----"
echo ""
echo "auth optional pam_faildelay.so delay=4000000" >> /etc/pam.d/system-login


echo "----- Disabling root access via SSH -----"
echo ""
echo "PermitRootLogin no" > /etc/ssh/sshd_config.d/20-deny-root.conf


echo "---------- npm & nodejs ----------"
echo ""
pacman -S --noconfirm nodejs npm


echo "---------- Neovim ----------"
echo ""
pacman -S --noconfirm neovim
rm -rf /home/"$name"/.config/nvim
git clone git@github.com:AntonyLoose/nvim-config.git /home/"$name"/.config/nvim
chown -R "$name:$name" /home/"$name"/.config/nvim


echo "----- Language Servers -----"
echo ""
pacman -S --noconfirm lua-language-server texlab
npm install -g typescript typescript-language-server vscode-langservers-extracted css-variables-language-server


echo "---------- i3 ----------"
echo ""
pacman -S --noconfirm i3-wm
rm -rf /home/"$name"/.config/i3
git clone <your-i3-repo-url> /home/"$name"/.config/i3
chown -R "$name:$name" /home/"$name"/.config/i3


echo "---------- picom ----------"
echo ""
pacman -S --noconfirm picom
rm -rf /home/"$name"/.config/picom
git clone <your-picom-repo-url> /home/"$name"/.config/picom
chown -R "$name:$name" /home/"$name"/.config/picom


echo "---------- Kitty ----------"
echo ""
pacman -S --noconfirm kitty
rm -rf /home/"$name"/.config/kitty
git clone <your-kitty-repo-url> /home/"$name"/.config/kitty
chown -R "$name:$name" /home/"$name"/.config/kitty


echo "---------- Neofetch ----------"
echo ""
pacman -S --noconfirm neofetch


echo "---------- Firefox ----------"
echo ""
pacman -S --noconfirm firefox


echo "---------- Snapper ----------"
echo ""
pacman -S --noconfirm snapper
snapper -c root create-config /

btrfs subvolume create /.snapshots
chmod 750 /.snapshots

echo "Updating /etc/fstab:"
blkid
read -p "UUID for root volume (e.g. UUID=xxxx-xxxx): " uuid
echo "$uuid /               btrfs  subvol=@             0 1" >> /etc/fstab
echo "$uuid /home           btrfs  subvol=@home         0 2" >> /etc/fstab
echo "$uuid /.snapshots     btrfs  subvol=@/.snapshots  0 0" >> /etc/fstab
mount -a


echo "----- Setting Permissions -----"
echo ""
chown "$name:$name" /.snapshots


echo "----- Auto Snapshots -----"
echo ""
pacman -S --noconfirm snapper-support
systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer

cat <<EOF >> /etc/snapper/configs/root
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="4"
TIMELINE_LIMIT_MONTHLY="6"
TIMELINE_LIMIT_YEARLY="1"
EOF


echo "----- Snapshots On Boot -----"
echo ""
pacman -S --noconfirm grub-btrfs
systemctl enable --now grub-btrfs.path


echo "----- Done -----"
