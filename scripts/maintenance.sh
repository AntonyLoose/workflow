#!/bin/bash
set -e

echo "----------------------------------------------------"
echo "Running as $user"
echo "----------------------------------------------------"

echo "----------------------------------------------------"
echo "Failed systemd services"
echo "----------------------------------------------------"
systemctl --failed
read -p "Press any key to continue" _

echo "----------------------------------------------------"
echo "UPDATING SYSTEM (OFFICIAL REPOS)"
echo "----------------------------------------------------"
sudo pacman -Syu

echo "----------------------------------------------------"
echo "REBUILDING AUR HELPER (if needed)"
echo "----------------------------------------------------"
if ! yay --version >/dev/null 2>&1; then
    echo "yay broken, rebuilding..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
fi

echo "----------------------------------------------------"
echo "UPDATING AUR PACKAGES"
echo "----------------------------------------------------"
yay -Syu --foreign

echo ""
echo "----------------------------------------------------"
echo "CLEARING PACMAN CACHE"
echo "----------------------------------------------------"
paccache -vrk2
paccache -ruk0

echo ""
echo "----------------------------------------------------"
echo "REMOVING ORPHANED PACKAGES"
echo "----------------------------------------------------"
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
    pacman -Rns $orphans
else
    echo "No orphaned packages."
fi

echo ""
echo "----------------------------------------------------"
echo "VACUUMING JOURNAL"
echo "----------------------------------------------------"
sudo journalctl --vacuum-time=7d
