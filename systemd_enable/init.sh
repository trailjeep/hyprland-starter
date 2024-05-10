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

if gum confirm --default=false "Do you want to enable Timeshift?"; then
  echo "Installing Timeshift..."
  sudo pacman -S --needed --noconfirm timeshift
  echo "Enabling cronie service"
  sudo systemctl enable --now cronie.service
else
  echo "Not enabling Timeshift"
fi

if gum confirm --default=false "Do you want to enable firewall?"; then
  echo "Installing firewalld"
  if [[ $(pacman -Qq iptables) ]]; then
    sudo pacman -Rdd --noconfirm iptables
  fi
  sudo pacman -S --needed --noconfirm firewalld python-pyqt5 python-capng
  echo "Enabling firewalld service"
  sudo systemctl enable --now firewalld.service
else
  echo "Not enabling firewall"
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
  sudo pacman -S --needed --noconfirm greetd
  current_user=$(whoami)
  sed -i "s|^user = \"diana\"|user = \"$current_user\"|" systemd_enable/config.toml
  sudo mv ~/hyprland-starter/systemd_enable/config.toml /etc/greetd
  sudo systemctl enable greetd.service
else
  echo "NOT autostarting hyprland upon system boot"
fi
