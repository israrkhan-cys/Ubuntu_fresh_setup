#!/bin/bash

set -e 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN} Ubuntu Essentials Tools Setup Script${NC}"
echo -e "${GREEN}================================================${NC}\n"

# the script must be run as root checking if 
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Get the actual user (not root)
ACTUAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

echo -e "${YELLOW}Installing for user: $ACTUAL_USER${NC}"
echo -e "${YELLOW}Home directory: $USER_HOME${NC}\n"

# Update system
echo -e "${GREEN}[1/10] Updating system packages...${NC}"
apt update && apt upgrade -y

# Install essential build tools and compilers
echo -e "${GREEN}[2/10] Installing build-essential (GCC, G++, Make)...${NC}"
apt install -y build-essential

# Install GDB (debugger)
echo -e "${GREEN}[3/10] Installing GDB debugger...${NC}"
apt install -y gdb

# Install Git
echo -e "${GREEN}[4/10] Installing Git...${NC}"
apt install -y git


# Install Python and pip
echo -e "${GREEN}[5/10] Installing Python, pip, and AI tools...${NC}"

apt install -y python3 python3-pip python3-venv

# Upgrade pip safely
python3 -m pip install --upgrade pip setuptools wheel

# Install Jupyter + AI/DS stack
python3 -m pip install \
    jupyterlab \
    notebook \
    numpy \
    pandas \
    matplotlib \



# Install VS Code
echo -e "${GREEN}[6/10] Installing Visual Studio Code...${NC}"
if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
    rm -f packages.microsoft.gpg
    apt update
    apt install -y code
    echo -e "${GREEN}VS Code installed successfully!${NC}"
else
    echo -e "${YELLOW}VS Code is already installed.${NC}"
fi


# Install Spotify
echo -e "${GREEN}[7/10] Installing Spotify...${NC}"
if ! command -v spotify &> /dev/null; then
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" > /etc/apt/sources.list.d/spotify.list
    apt update
    apt install -y spotify-client
    echo -e "${GREEN}Spotify installed successfully!${NC}"
else
    echo -e "${YELLOW}Spotify is already installed.${NC}"
fi


# Install other useful tools
echo -e "${GREEN}[8/10] Installing additional useful tools...${NC}"
apt install -y \
    curl \
    wget \
    vim \
    nano \
    htop \
    tree \
    zip \
    unzip \
    net-tools \
    gnome-tweaks \
    gnome-shell-extensions
    






# =================  Set wallpaper ===================  
echo -e "${GREEN} Setting a wallpaper...${NC}"
WALLPAPER_DIR="$USER_HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_DIR"
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$WALLPAPER_DIR"

# Download a nice programming-themed wallpaper
WALLPAPER_URL="https://images.unsplash.com/photo-1542831371-29b0f74f9713"
WALLPAPER_PATH="$WALLPAPER_DIR/code_wallpaper.jpg"

sudo -u "$ACTUAL_USER" wget -O "$WALLPAPER_PATH" "$WALLPAPER_URL?w=1920&h=1080&fit=crop" 2>/dev/null || {
    echo -e "${YELLOW}Could not download wallpaper. Skipping...${NC}"
}

if [ -f "$WALLPAPER_PATH" ]; then
    # Set wallpaper for GNOME
    sudo -u "$ACTUAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $ACTUAL_USER)/bus" \
        gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
    sudo -u "$ACTUAL_USER" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $ACTUAL_USER)/bus" \
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
    echo -e "${GREEN}Wallpaper set successfully!${NC}"
fi



# ======== ====  Clean up ==================
echo -e "${GREEN}Cleaning up...${NC}"
apt autoremove -y
apt clean


echo -e "\n${GREEN}================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}================================================${NC}\n"
echo -e "3. Restart your system to ensure all changes take effect"


echo ""
echo -e "\n${GREEN}Welcome to the penguin cult! ${NC}\n"