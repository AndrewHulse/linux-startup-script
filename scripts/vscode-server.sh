#!/bin/bash
#
# Install VS Code Server (code-server)
#

set -e

echo "Installing VS Code Server (code-server)..."

# Install code-server using the official install script
curl -fsSL https://code-server.dev/install.sh | sh

# Enable and start code-server service
sudo systemctl enable --now code-server@$USER

# Wait a moment for the service to start
sleep 2

# Get the password from the config file
if [ -f ~/.config/code-server/config.yaml ]; then
    PASSWORD=$(grep "^password:" ~/.config/code-server/config.yaml | awk '{print $2}')
fi

echo "✓ VS Code Server installed successfully"
echo ""
echo "  Service status: $(sudo systemctl is-active code-server@$USER)"
echo "  Config: ~/.config/code-server/config.yaml"
echo ""
echo "  Access VS Code Server at: http://localhost:8080"
if [ -n "$PASSWORD" ]; then
    echo "  Password: $PASSWORD"
fi
echo ""
echo "  To change the password, edit: ~/.config/code-server/config.yaml"
echo "  Then restart: sudo systemctl restart code-server@$USER"
