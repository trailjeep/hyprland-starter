#!/bin/bash

trap 'exit 1' INT
trap 'kill 0' EXIT

sudo_loop() {
    while :; do
        sleep 30
        sudo -v &> /dev/null || break
    done &
}

if sudo -v; then
    sudo_loop
else
    exit 1
fi

version=$(cat .version/name)
source ./library.sh

echo "Welcome to the hyprland starter script."
cat <<"EOF"
 _   _                  _                 _   _____ _   _ ___
| | | |_   _ _ __  _ __| | __ _ _ __   __| | |_   _| | | |_ _|
| |_| | | | | '_ \| '__| |/ _` | '_ \ / _` |   | | | | | || |
|  _  | |_| | |_) | |  | | (_| | | | | (_| |   | | | |_| || |
|_| |_|\__, | .__/|_|  |_|\__,_|_| |_|\__,_|   |_|  \___/|___|
       |___/|_|
 ___           _        _ _
|_ _|_ __  ___| |_ __ _| | | ___ _ __
 | || '_ \/ __| __/ _` | | |/ _ \ '__|
 | || | | \__ \ || (_| | | |  __/ |
|___|_| |_|___/\__\__,_|_|_|\___|_|

EOF
echo "Version: $version"
echo "Script made by Diana"
echo "This script is made to guide you though the process of installing Hyprland and theming."

read -p "Press enter to continue the script and install script dependencies."
source ./script_dependencies/init.sh
echo "Updating packages mirror list so we can get the latest and greatest packages."
_PackagesMirrorListSyncPacman
source ./aur_wrapper/init.sh
source ./general_packages/init.sh
source ./backup_dotfiles/init.sh
source ./gpu_drivers/init.sh
source ./hyprland_dependencies/init.sh
source ./profiles/init.sh # rice and dotfiles dependencies:
source ./systemd_enable/init.sh
source ./keyboard/init.sh

if gum confirm --default="no" "Is this a laptop?"; then
    echo "Running additional scripts to make this laptop usage."
    source ./qolfixes/init.sh
    source ./workarounds/init.sh
    echo "More Comming soon"
else
    echo "Running additional scripts for desktop usage."
    echo "Comming Soon"
fi

source ./wallpaper/init.sh
source ./vm_support/init.sh
source ./cleanup/init.sh

figlet "Done"
# ------------------------------------------------------
# Reboot
# ------------------------------------------------------

echo -e "${GREEN}"
figlet "Reboot"
echo -e "${NONE}"
echo "A reboot of your system is recommended."
if gum confirm "Do you want to reboot your system now?" ;then
    echo ":: Rebooting now ..."
    sleep 3
    systemctl reboot
elif [ $? -eq 130 ]; then
    exit 130
else
    echo ":: Reboot skipped"
fi
echo ""

