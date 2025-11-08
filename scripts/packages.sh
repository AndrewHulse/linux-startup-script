#!/bin/bash
#
# Install basic packages
#

set -e

# Sudo wrapper - use sudo only if not root and sudo exists
run_as_root() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    elif command -v sudo &> /dev/null; then
        sudo "$@"
    else
        "$@"  # Try without sudo as fallback
    fi
}

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

run_as_root apt install -y "${PACKAGES[@]}"

echo "✓ Basic packages installed successfully"
