#!/bin/bash

# Variables
USER_NAME=$(whoami)
CHROME_DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

# Update the system
echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

# Add current user to sudo group (Kali usually already has this)
echo "[*] Adding $USER_NAME to sudo group..."
sudo usermod -aG sudo $USER_NAME

# Install essential packages
echo "[*] Installing essential packages (curl, wget, zsh, git)..."
sudo apt install -y curl wget apt-transport-https software-properties-common vim git zsh

# Install Oh My Zsh
echo "[*] Installing Oh My Zsh..."
if ! command -v zsh &> /dev/null; then
    echo "Zsh is not installed. Aborting."
    exit 1
fi

# Install Oh My Zsh non-interactively, skip changing shell inside install script
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
  echo "Failed to install Oh My Zsh."
  exit 1
}

# Change default shell to zsh for current user
echo "[*] Changing shell to zsh..."
chsh -s "$(which zsh)" $USER_NAME

# Install Google Chrome
echo "[*] Downloading and installing Google Chrome..."
wget -O /tmp/chrome.deb $CHROME_DEB_URL
sudo dpkg -i /tmp/chrome.deb || sudo apt-get install -f -y
rm /tmp/chrome.deb

# Install Docker and Docker Compose
echo "[*] Installing Docker dependencies..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "[*] Adding Docker's official GPG key and repo..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

DISTRO_CODENAME="bullseye"  # Hardcoded Debian codename for Kali compatibility

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $DISTRO_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

echo "[*] Installing Docker Engine and Compose..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
echo "[*] Adding $USER_NAME to docker group..."
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER_NAME

echo "[*] Installation complete. Please logout and login again or reboot for changes to take effect."
