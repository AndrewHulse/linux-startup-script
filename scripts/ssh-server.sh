#!/bin/bash
#
# Install and configure SSH server
#

set -e

echo "Setting up SSH server..."

# Install OpenSSH server
sudo apt install -y openssh-server

# Start and enable SSH service
sudo systemctl start ssh
sudo systemctl enable ssh

echo "✓ SSH server installed and started"

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo ""
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "Drew.hulse.home@gmail.com" -f ~/.ssh/id_ed25519 -N ""
    echo "✓ SSH key generated"
else
    echo "  SSH key already exists at ~/.ssh/id_ed25519"
fi

# Display the public key
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "SSH PUBLIC KEY (copy this to remote machines for SSH access):"
echo "════════════════════════════════════════════════════════════════"
echo ""
cat ~/.ssh/id_ed25519.pub
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""

# Display connection information
echo "SSH Server Information:"
echo "  Status: $(sudo systemctl is-active ssh)"
echo "  Port: 22 (default)"
if command -v hostname &> /dev/null; then
    echo "  Hostname: $(hostname)"
fi
if command -v ip &> /dev/null; then
    LOCAL_IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n1)
    echo "  Local IP: $LOCAL_IP"
fi
echo ""
echo "To connect from another machine, use:"
echo "  ssh $(whoami)@<this-machine-ip>"
echo ""
