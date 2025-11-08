#!/bin/bash
#
# Install and configure TMUX from GitHub repository
#

set -e

# Sudo wrapper
run_as_root() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    elif command -v sudo &> /dev/null; then
        sudo "$@"
    else
        "$@"
    fi
}

echo "Installing TMUX configuration..."

# Install tmux if not already installed
if ! command -v tmux &> /dev/null; then
    run_as_root apt install -y tmux
fi

# Backup existing tmux config if it exists
if [ -f ~/.tmux.conf ]; then
    echo "  Backing up existing ~/.tmux.conf to ~/.tmux.conf.backup"
    mv ~/.tmux.conf ~/.tmux.conf.backup
fi

# Clone TMUX configuration repository
TEMP_DIR=$(mktemp -d)
git clone https://github.com/AndrewHulse/TMUX-Configurations.git "$TEMP_DIR"

# Copy configuration files
if [ -f "$TEMP_DIR/.tmux.conf" ]; then
    cp "$TEMP_DIR/.tmux.conf" ~/.tmux.conf
    echo "✓ TMUX configuration installed successfully"
else
    echo "  Warning: .tmux.conf not found in repository, copying all files..."
    cp -r "$TEMP_DIR/"* ~/
    echo "✓ TMUX files copied to home directory"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "  Configuration: ~/.tmux.conf"
