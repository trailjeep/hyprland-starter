figlet "Systemd Conf"

echo "This section is for autostarting hyprland, enabling bluetooth support and among other things"

if gum confirm "Do you want to enable bluetooth service?"; then
  echo "Installing bluetooth dependencies..."
  sudo pacman -S --needed --noconfirm bluez bluez-utils
  echo "Enabling bluetooth service"
  sudo systemctl enable --now bluetooth.service
else
  echo "Not enabling bluetooth service"
fi

# FIXME ask cronie regardless
if gum confirm --default=false "Do you want to enable Timeshift?"; then
  echo "Installing Timeshift..."
  sudo pacman -S --needed --noconfirm timeshift grub-btrfs
  sudo cp ~/hyprland-starter/systemd_enable/timeshift-autosnap.conf /etc/timeshift-autosnap.conf
  echo "Enabling cronie service"
  sudo systemctl enable --now cronie.service
else
  echo "Not enabling Timeshift"
fi

if gum confirm --default=false "Do you want to enable firewall?"; then
  echo "Installing firewalld"
  if _isInstalledPacman iptables; then
    sudo pacman -Rdd --noconfirm iptables
  fi
  sudo pacman -S --needed --noconfirm firewalld python-pyqt5 python-capng
  echo "Enabling firewalld service"
  sudo systemctl enable --now firewalld.service
else
  echo "Not enabling firewall"
fi

if ! _isInstalledPacman plocate; then
  if gum confirm "Do you want to install plocate?"; then
    echo "Installing plocate"
    if _isInstalledPacman mlocate; then
      sudo pacman -Rdd --noconfirm mlocate
    fi
    sudo pacman -S --needed --noconfirm plocate
    echo "Enabling updatedb service"
    sudo systemctl enable --now plocate-updatedb.timer
  else
    echo "Not installing plocate"
  fi
fi

if gum confirm --default=false "Do you want to enable printing?"; then
  echo "Installing printing dependencies..."
  sudo pacman -S --needed --noconfirm cups cups-browsed cups-filters cups-pdf foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds foomatic-db-gutenprint-ppds ghostscript gsfonts gutenprint nss-mdns avahi
  echo "Enabling avahi & cups services"
  sudo sed -i 's/mymachines resolve/mymachines mdns_minimal [NOTFOUND=return] resolve/' /etc/nsswitch.conf
  sudo systemctl enable --now avahi-daemon.service
  sudo systemctl enable --now cups.socket
  sudo systemctl start cups.service
  echo "cups.service started to configure printers on localhost:631"
else
  echo "Not enabling printing service"
fi

if gum confirm --default=false "Do you want to switch to zen kernel?"; then
  echo "Installing zen kernel..."
  sudo pacman -S --needed --noconfirm linux-zen linux-zen-headers
  #sudo sed -i 's/GRUB_DEFAULT=.*$/GRUB_DEFAULT=saved/' /etc/default/grub
  #sudo sed -i '/GRUB_DEFAULT=.*$/aGRUB_SAVEDEFAULT=true' /etc/default/grub
  #sudo sed -i 's/GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=2/' /etc/default/grub
  #sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  echo "Not installing zen kernel"
fi

#if gum confirm --default=false "Do you want to add LTS kernel?"; then
#  echo "Installing LTS kernel..."
#  sudo pacman -S --needed --noconfirm linux-lts linux-lts-headers
#else
#  echo "Not installing zen kernel"
#fi

if gum confirm --default=false "Do you want to setup swap on ZRAM?"; then
  echo "Installing ZRAM..."
  # FIXME
  # yay -S --needed --noconfirm systemd-zram
  # sudo systemctl enable --now systemd-zram.service
else
  echo "Not installing ZRAM"
fi

if gum confirm --default=false "Do you want to install KVM / QEMU / VMM / Boxes?"; then
  echo "Installing dependencies..."
  sudo pacman -S --needed --noconfirm virt-manager qemu-desktop libvirt edk2-ovmf dnsmasq vde2 bridge-utils iptables-nft dmidecode gnome-boxes
  echo "Configuring..."
  sudo usermod -aG libvirt "$(whoami)"
  sudo usermod -aG kvm "$(whoami)"
  sudo systemctl enable --now libvirtd.socket
  sudo virsh net-autostart default
  #sudo rmdir /var/lib/libvirt/images/
  #sudo ln -s /mnt/VMs/libvirt/images/ /var/lib/libvirt/
else
  echo "Not installing KVM / QEMU / VMM / Boxes."
fi

echo "Current method of autostarting Hyprland is using greetd"

if gum confirm "Do you want to autostart hyprland upon system boot?"; then
  echo "Installing greetd..."
  sudo pacman -S --needed --noconfirm greetd greetd-tuigreet
  current_user=$(whoami)
  sed -i "s|^user = \"diana\"|user = \"$current_user\"|" systemd_enable/config.toml
  sudo mv ~/hyprland-starter/systemd_enable/config.toml /etc/greetd
  sudo systemctl enable greetd.service
else
  echo "NOT autostarting hyprland upon system boot"
fi

# Misc

# ucode
cpu=$(cat /proc/cpuinfo | grep -m1 vendor_id | awk -F: '{print $2}' | tr 'A-Z' 'a-z')
if [[ "$cpu" == *"amd"* ]]; then
  sudo pacman -S --needed --noconfirm amd-ucode
elif [[ "$cpu" == *"intel"* ]]; then
  sudo pacman -S --needed --noconfirm intel-ucode
fi

# Flatpak
sudo pacman -S --needed --noconfirm flatpak gnome-software
flatpak override --filesystem=~/.themes:ro --filesystem=~/.icons:ro --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtk-4.0:ro --user
sudo flatpak override --filesystem=~/.themes:ro --filesystem=~/.icons:ro --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtk-4.0:ro

# reflector
sudo sed -i 's/# --country .*$/--country US,CA/' /etc/xdg/reflector/reflector.conf
sudo systemctl enable --now reflector.timer

# xdg-desktop-portal-gtk possible waybar conflict
if _isInstalledPacman xdg-desktop-portal-gtk; then
  sudo pacman -R xdg-desktop-portal-gtk
fi

# kde dolphin / gwenview
if _isInstalledPacman baloo; then
  balooctl6 disable
fi

# informant
sudo groupadd informant
sudo touch /var/lib/informant.dat
sudo chown root:informant /var/lib/informant.dat
sudo chmod a+w /var/lib/informant.dat

# Mountpoints
sudo mkdir /mnt/VMs /mnt/Public /mnt/"$USER" /mnt/eBooks /mnt/Movies /mnt/Music /mnt/Podcasts /mnt/TEMP

# Issue
cat << _EOF_ | sudo tee /etc/issue
**************** WARNING **************
\n is a secure system!       
All activities are monitored!
Unauthorized access prohibited!
***************************************
_EOF_

