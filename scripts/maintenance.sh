#!/bin/bash
# reference: https://github.com/kurealnum/dotfiles/blob/main/.config/scripts/sysmaintenance.sh

echo "----------------------------------------------------"
echo "Failed systemd services"
echo "----------------------------------------------------"

systemctl --failed
read -p "Press any key to continue" _

echo "----------------------------------------------------"
echo "UPDATING SYSTEM"
echo "----------------------------------------------------"

yay -Qu
echo "The following packages will be updated."
read -p "Press any key to continue" _

yay -Syu

echo ""
echo "----------------------------------------------------"
echo "CLEARING PACMAN CACHE"
echo "----------------------------------------------------"

pacman_cache_space_used="$(du -sh /var/cache/pacman/pkg/)"
echo "Space currently in use: $pacman_cache_space_used"
echo ""
echo "Clearing Cache, leaving newest 2 versions:"
paccache -vrk2
echo ""
echo "Clearing all uninstalled packages:"
paccache -ruk0

echo ""
echo "----------------------------------------------------"
echo "REMOVING ORPHANED PACKAGES"
echo "----------------------------------------------------"

orphaned=$(pacman -Qtd)
if [ -n "$orphaned" ]; then
    echo "Removing:"
    echo "$orphaned"
    yay -Qm
else
    echo "No orphaned packages to remove."
fi

echo ""
echo "----------------------------------------------------"
echo "CLEARING HOME CACHE"
echo "----------------------------------------------------"

home_cache_used="$(du -sh ~/.cache)"
rm -rf ~/.cache/
echo "Clearing ~/.cache/..."
echo "Spaced saved: $home_cache_used"

echo ""
echo "----------------------------------------------------"
echo "CLEARING SYSTEM LOGS"
echo "----------------------------------------------------"

sudo journalctl --vacuum-time=7d
echo ""

