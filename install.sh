# Clear terminal input
clear

# Define colors.
GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
NO_COLOR='\e[0m'

# Welcome text.
echo -e "${YELLOW}---Raspberry Pi Configuration for Arch Linux---
Script by Manuinder Sekhon
https://github.com/ManuSekhon/raspberrypi-arch-dotfiles
${NO_COLOR}"

# Ask for administrator password.
echo -e "\nInstallation requires administrator authentication..."
sudo -v

# Try to keep `sudo` alive i.e. update existing time stamp until `./install.sh` has finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Helper Function: Start and validate system services
start_service() {
    local service_name="$1"
    echo -e "- Starting service:${YELLOW} $service_name ${NO_COLOR}"
    # Start service
    sudo systemctl start "$service_name"
    # Register this service to start at boot.
    sudo systemctl enable "$service_name"

    # Get service status.
    local is_active=$(systemctl show -p ActiveState --value "$service_name")
    local is_running=$(systemctl show -p SubState --value "$service_name")

    if [ "$is_active" = "active" ] && [ "$is_running" = "running" ]; then
        echo -e "${GREEN}$service_name is active and running${NO_COLOR}."
    else
        echo -e "${RED}$service_name failed to start${NO_COLOR}."
    fi
}

# Save current user path.
script_path=$(pwd)

# Move to home directory during installation.
cd ~

echo -e "\nStarting setup...\n"
echo -e "Starting system services..."

# Bluetooth
start_service "bluetooth.service"
# Network manager. (Starts wifi, ethernet)
start_service "NetworkManager.service"
# systemd-networkd (needed by network manager)
start_service "systemd-networkd"
# SSH service
start_service "sshd.service"

echo -e "${GREEN}Starting system services successful.${NO_COLOR}\n"

# Update pacman mirrors list for faster download performance.
echo -e "Getting top 20 fastest mirrors to download packages..."
sudo pacman-mirrors --fasttrack 20 1> /dev/null

# Full system upgrade.
echo -e "Upgrading system..."
yes | sudo pacman -Syyu 1> /dev/null
echo -e "${GREEN}System upgrade successful.${NO_COLOR}\n"

# List of pacman packages. Some of development packages are needed for flutter linux builds.
pacman_packages=(
    "base-devel"
    "git"
    "curl"
    "net-tools"
    "neofetch"
    "clang"
    "cmake"
    "pkg-config"
    "ninja"
    "gtk3"
    "vim"
    "ranger"
    "tigervnc"
    "redis"
    "python"
)

# Install pacman packages.
echo -e "Installing pacman packages..."
for package in "${pacman_packages[@]}"
do
    echo -e "- Installing: ${YELLOW}$package${NO_COLOR}"
    sudo pacman -S "$package" --noconfirm 1> /dev/null
    echo -e "${GREEN}$package installed.${NO_COLOR}"
done
echo -e "${GREEN}Installing pacman packages successful.${NO_COLOR}\n"

# Register redis service to start at boot.
echo -e "Registering Redis service to start at boot..."
start_service "redis.service"
echo -e "Pinging Redis CLI -> Response is ${YELLOW}$(redis-cli ping)${NO_COLOR}\n"

# Installing python dependencies.
echo -e "Installing python dependencies (pip, setuptools, wheel)..."
curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py -#
python get-pip.py 1> /dev/null
echo -e "Fixing pip paths..."
python -m ensurepip 1> /dev/null
rm -rf get-pip.py 1> /dev/null

# Use python virtual environment for projects.
echo -e "Installing python virtualenv..."
pip install virtualenv 1> /dev/null

echo -e "${GREEN}Installing python dependencies successful.${NO_COLOR}\n"

# Install `yay` package manager for AUR.
echo -e "Installing yay package manager for AUR..."
sudo pacman -S yay --noconfirm 1> /dev/null
yay --save --answerclean All --answerdiff None
echo -e "${GREEN}Installing yay successful.${NO_COLOR}\n"

# Install ZSH
echo -e "Installing ZSH..."
yay -S zsh --noconfirm 1> /dev/null

# Use ZSH as default shell.
echo -e "Changing default shell to ZSH..."
sudo chsh -s /bin/zsh 1> /dev/null

# Oh my ZSH variant for pretty pre-configured settings.
echo -e "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install some third party plugins for easy usage.
echo -e "Installing ZSH plugins..."
git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --quiet https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone --quiet https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/autoswitch_virtualenv
echo -e "${GREEN}Installing ZSH successful.${NO_COLOR}\n"

# Install visual studio code
echo -e "Installing Visual Studio Code..."
yay -S visual-studio-code-bin --noconfirm 1> /dev/null

# Pre install useful vscode extensions.
echo -e "\nInstalling flutter extension..."
code --install-extension dart-code.flutter 1> /dev/null
echo -e "${GREEN}Installing Visual Studio Code successful.${NO_COLOR}\n"

# Install flutter.
echo -e "Installing Flutter..."
git clone --quiet https://github.com/flutter/flutter.git -b stable
$HOME/flutter/bin/flutter doctor -v &> /dev/null
echo -e "${GREEN}Installing Flutter successful.${NO_COLOR}\n"

# Raspberry PI configuration.
echo -e "Configuring Raspberry PI Hardware..."

# Enable SPI pins at boot.
echo -e "- Enabling SPI pins..."
sudo sh -c "echo 'device_tree_param=spi=on' >> /boot/config.txt"

# Enable I2C pins at boot.
echo -e "- Enabling I2C pins..."
sudo sh -c "echo 'dtparam=i2c_arm=on' >> /boot/config.txt"

# Install pacman modules for I2C.
echo -e "- Installing I2C modules..."
sudo pacman -S i2c-tools lm_sensors libgpiod --noconfirm 1> /dev/null

# Load I2C modules at startup.
echo -e "- Configure I2C modules to load at startup..."
echo "i2c-dev i2c-bcm2708" | sudo tee -a /etc/modules-load.d/raspberrypi.conf

# Allow GPIO, SPI and I2C access without root permissions.
echo -e "- Configuring GPIO, SPI and I2C interface access without root permissions..."
sudo tee -a /usr/lib/udev/rules.d/99-spi-permissions.rules << END
KERNEL=="spidev*", GROUP="$USER", MODE="0660"
SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c 'chown -R root:$USER /sys/class/gpio && chmod -R 775 /sys/class/gpio; chown -R root:$USER /sys/devices/virtual/gpio && chmod -R 775 /sys/devices/virtual/gpio; chown -R root:$USER /sys/devices/platform/soc/*.gpio/gpio && chmod -R 775 /sys/devices/platform/soc/*.gpio/gpio'"
SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:$USER /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", PROGRAM="/bin/sh -c 'chown root:$USER /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
END

echo -e "${GREEN}Configuring Raspberry PI Hardware successful.${NO_COLOR}\n"

# Insalling libraries for GPIO pin testing.
echo -e "Installing libraries for GPIO pin testing..."
yay -S pigpio --noconfirm 1> /dev/null
curl http://abyz.me.uk/rpi/pigpio/code/gpiotest.zip -o gpiotest.zip -#
unzip gpiotest.zip 1> /dev/null
rm -rf gpiotest.zip
chmod a+x gpiotest
echo -e "${GREEN}Installing libraries for GPIO pin testing successful.${NO_COLOR}\n"

# Backup old .zshrc
echo -e "Backing up old .zshrc..."
mv $HOME/.zshrc $HOME/.zshrc.bak
rm -rf $HOME/.zshrc

# Replace with fixed paths and aliases.
echo -e "Replacing .zshrc with the one included in this script..."
cp $script_path/.zshrc $HOME

# Move back to user's folder.
cd $script_path

# Voila!
echo -e "\n${GREEN}Installation complete!\n${RED}Restart your system for changes to take effect\n"

echo -e "${YELLOW}Refer to README.md included with this script to know how to: 
* use GPIO pin testing
* start remote desktop VNC
* and details of settings done above.
  https://github.com/ManuSekhon/raspberrypi-arch-dotfiles${NO_COLOR}
"