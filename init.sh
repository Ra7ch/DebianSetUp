#!/bin/bash

# Variables
USER_NAME=$(whoami)
CHROME_DEB_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

# Update the system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Add current user to sudo group
echo "Adding $USER_NAME to sudoers..."
sudo usermod -aG sudo $USER_NAME

# Install essential packages
echo "Installing essential packages..."
sudo apt install -y curl wget apt-transport-https software-properties-common build-essential vim git zsh

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
if ! [ -x "$(command -v zsh)" ]; then
  echo "Zsh is not installed. Aborting."
  exit 1
fi
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
  echo "Failed to install Oh My Zsh."
}

# Change shell to Zsh
echo "Changing shell to Zsh..."
chsh -s $(which zsh)

# Install Google Chrome
echo "Installing Google Chrome..."
wget -O chrome.deb $CHROME_DEB_URL
sudo dpkg -i chrome.deb || sudo apt-get -f install -y  # Fix dependencies if necessary
rm chrome.deb

# Install Docker
echo "Installing Docker..."
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key and repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to the Docker group
echo "Adding $USER_NAME to the Docker group..."
sudo usermod -aG sudo docker || echo "Docker group already in sudoers."
sudo groupadd docker || echo "Docker group already exists."
sudo usermod -aG docker $USER_NAME

# Install Python and development tools
echo "Installing Python and development tools..."
sudo apt install -y python3 python3-pip python3-venv
pip3 install --upgrade pip setuptools wheel
pip3 install django tensorflow numpy

# Install VS Code
echo "Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install -y code

# Install VS Code Copilot extension
echo "Installing Copilot extension for VS Code..."
code --install-extension GitHub.copilot --force

echo "Installing python tools"
sudo pip install django daphne tensorflow numpy keras whitenoise channels channels-redis gym --break-system-packages

echo "setting up ssh"
ssh-keygen

# Final step
echo "Setup complete. Please restart your terminal or system to apply all changes."
