#!/bin/bash
#
# Install Hyperion Neofetch configuration from GitHub
#

set -e

# Sudo wrapper
run_as_root() {
    if [ "$EUID" -eq 0 ]; then
        "$@"
    elif command -v sudo &> /dev/null; then
        run_as_root "$@"
    else
        "$@"
    fi
}

echo "Installing Neofetch configuration..."

# Install neofetch if not already installed
if ! command -v neofetch &> /dev/null; then
    run_as_root apt install -y neofetch
fi

# Install Python3 for logo conversion script
if ! command -v python3 &> /dev/null; then
    run_as_root apt install -y python3
fi

# Create config directory
mkdir -p ~/.config/neofetch

# Backup existing config if it exists
if [ -f ~/.config/neofetch/config.conf ]; then
    echo "  Backing up existing config to ~/.config/neofetch/config.conf.backup"
    mv ~/.config/neofetch/config.conf ~/.config/neofetch/config.conf.backup
fi

# Clone neofetch configuration repository
TEMP_DIR=$(mktemp -d)
git clone https://github.com/AndrewHulse/hyperion-neofetch.git "$TEMP_DIR"

# Create permanent directory for logo files
NEOFETCH_DIR=~/claude/neofetch_wiz
mkdir -p "$NEOFETCH_DIR"

# Copy logo files to permanent location
cp "$TEMP_DIR/logo_binary.txt" "$NEOFETCH_DIR/"
cp "$TEMP_DIR/logo_plain.txt" "$NEOFETCH_DIR/"
cp "$TEMP_DIR/convert_binary_logo.py" "$NEOFETCH_DIR/"

# Copy and update config file
cp "$TEMP_DIR/config.conf" ~/.config/neofetch/config.conf

# Update image_source path in config if needed
sed -i "s|image_source=.*|image_source=\"$NEOFETCH_DIR/logo_binary.txt\"|g" ~/.config/neofetch/config.conf

# Cleanup
rm -rf "$TEMP_DIR"

echo "✓ Neofetch configuration installed successfully"
echo "  Config: ~/.config/neofetch/config.conf"
echo "  Logo files: $NEOFETCH_DIR"
echo ""
echo "  Run 'neofetch' to see your custom configuration!"
