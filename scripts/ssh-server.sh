#!/bin/bash
#
# Install and configure SSH server
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

echo "Setting up SSH server..."

# Install OpenSSH server
run_as_root apt install -y openssh-server

# Start SSH service - detect systemd vs non-systemd environments
if [ -d /run/systemd/system ]; then
    # systemd is available
    run_as_root systemctl start ssh
    run_as_root systemctl enable ssh
    echo "✓ SSH server installed and started (systemd)"
else
    # Non-systemd environment (Docker, etc.)
    # Create run directory if it doesn't exist
    run_as_root mkdir -p /run/sshd

    # Start SSH daemon directly
    if command -v service &> /dev/null; then
        run_as_root service ssh start 2>/dev/null || run_as_root /usr/sbin/sshd
    else
        run_as_root /usr/sbin/sshd
    fi
    echo "✓ SSH server installed and started (manual)"
fi

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
if [ -d /run/systemd/system ]; then
    echo "  Status: $(run_as_root systemctl is-active ssh)"
else
    if pgrep -x sshd > /dev/null; then
        echo "  Status: active"
    else
        echo "  Status: inactive"
    fi
fi
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
