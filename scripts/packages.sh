#!/bin/bash
#
# Install basic packages
#

set -e

echo "Installing basic packages..."

PACKAGES=(
    curl
    wget
    git
    vim
    nano
    htop
    tmux
    tree
    unzip
    zip
    build-essential
    software-properties-common
    ca-certificates
    gnupg
    lsb-release
)

sudo apt install -y "${PACKAGES[@]}"

echo "✓ Basic packages installed successfully"
