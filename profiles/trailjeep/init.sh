figlet "Trailjeep's Dotfiles"
source ./library.sh
read -p "Press enter to continue install the dotfiles."

echo "Downloading packages"
_installPackageAur "profiles/trailjeep/packages.txt"
_installPackageAur "profiles/trailjeep/fonts.txt"
_installPackageAur "profiles/trailjeep/apps.txt"
_installPackagesFlatpak "profiles/trailjeep/flatpak.txt"

echo "Downloading dotfiles"
cd ~/
git clone https://github.com/dianaw353/starter-dotfile.git ~/dotfiles --depth=1
cd ~/dotfiles

# Installing GTK Files
# Remove existing symbolic links
gtk_symlink=0
gtk_overwrite=1
if [ -L ~/.config/gtk-3.0 ]; then
  rm ~/.config/gtk-3.0
  gtk_symlink=1
fi

if [ -L ~/.config/gtk-4.0 ]; then
  rm ~/.config/gtk-4.0
  gtk_symlink=1
fi

if [ -L ~/.gtkrc-2.0 ]; then
  rm ~/.gtkrc-2.0
  gtk_symlink=1
fi

if [ -L ~/.Xresources ]; then
  rm ~/.Xresources
  gtk_symlink=1
fi

if [ "$gtk_symlink" == "1" ] ;then
  echo ":: Existing symbolic links to GTK configurations removed"
fi

if [ -d ~/.config/gtk-3.0 ] ;then
  echo "The script has detected an existing GTK configuration."
  if gum confirm "Do you want to overwrite your configuration?" ;then
    gtk_overwrite=1
  else
    gtk_overwrite=0
  fi
fi

if [ "$gtk_overwrite" == "1" ] ;then
  cp -r gtk/gtk-3.0 ~/.config/
  cp -r gtk/gtk-4.0 ~/.config/
  cp -r gtk/xsettingsd ~/.config/
  cp gtk/.gtkrc-2.0 ~/
  cp gtk/.Xresources ~/
  echo ":: GTK Theme installed"
fi

echo "Installing dotfiles"
if [ -d ~/dotfiles/alacritty ]; then
    _installSymLink alacritty ~/.config/alacritty ~/dotfiles/alacritty ~/.config
fi
if [ -d ~/dotfiles/hypr ]; then
    _installSymLink hypr ~/.config/hypr ~/dotfiles/hypr ~/.config
fi
if [ -d ~/dotfiles/dunst ]; then
    _installSymLink dunst ~/.config/dunst ~/dotfiles/dunst ~/.config
fi
if [ -d ~/dotfiles/rofi ]; then
    _installSymLink rofi ~/.config/rofi ~/dotfiles/rofi ~/.config
fi
if [ -d ~/dotfiles/scripts ]; then
    _installSymLink scripts ~/.config/scripts ~/dotfiles/scripts ~/.config
fi
if [ -d ~/dotfiles/starship ]; then
    _installSymLink starship ~/.config/starship ~/dotfiles/starship ~/.config
fi
if [ -d ~/dotfiles/waybar ]; then
    _installSymLink waybar ~/.config/waybar ~/dotfiles/waybar ~/.config
fi
if [ -d ~/dotfiles/wlogout ]; then
    _installSymLink wlogout ~/.config/wlogout ~/dotfiles/wlogout ~/.config
fi
if [ -d ~/dotfiles/.zshrc ]; then
  _installSymLink .zshrc ~/.zshrc ~/dotfiles/.zshrc ~/
fi
if [ -d ~/dotfiles/wal ]; then
  _installSymLink wal ~/.config/wal ~/dotfiles/wal ~/.config
fi
if [ -d ~/dotfiles/wal ]; then
  _installSymLink .zsh_aliases ~/.zsh_aliases ~/dotfiles/.zsh_aliases ~/
fi

mkdir ~/.cache
mkdir ~/Pictures/
mkdir ~/Pictures/screenshots
cd ~/hyprland-starter

sudo -u $(whoami) bash << _EOF_
chsh -s /bin/zsh
_EOF_
