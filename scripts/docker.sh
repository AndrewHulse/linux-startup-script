#!/bin/bash
#
# Install Docker
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

echo "Installing Docker..."

# Remove old versions if they exist
run_as_root apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Install prerequisites (already done in packages.sh, but ensuring they exist)
run_as_root apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
run_as_root mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | run_as_root gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | run_as_root tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
run_as_root apt update

# Install Docker Engine
run_as_root apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
run_as_root usermod -aG docker $USER

echo "✓ Docker installed successfully"
echo ""
echo "  Docker version: $(docker --version)"
echo "  Docker Compose version: $(docker compose version)"
echo ""
echo "  Note: You may need to log out and back in for group permissions to take effect."
echo "  After logging back in, you can run Docker commands without sudo."
