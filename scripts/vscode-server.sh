#!/bin/bash
#
# Install VS Code Server (code-server)
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

echo "Installing VS Code Server (code-server)..."

# Install code-server using the official install script
curl -fsSL https://code-server.dev/install.sh | sh

# Enable and start code-server service
run_as_root systemctl enable --now code-server@$USER

# Wait a moment for the service to start
sleep 2

# Get the password from the config file
if [ -f ~/.config/code-server/config.yaml ]; then
    PASSWORD=$(grep "^password:" ~/.config/code-server/config.yaml | awk '{print $2}')
fi

echo "✓ VS Code Server installed successfully"
echo ""
echo "  Service status: $(run_as_root systemctl is-active code-server@$USER)"
echo "  Config: ~/.config/code-server/config.yaml"
echo ""
echo "  Access VS Code Server at: http://localhost:8080"
if [ -n "$PASSWORD" ]; then
    echo "  Password: $PASSWORD"
fi
echo ""
echo "  To change the password, edit: ~/.config/code-server/config.yaml"
echo "  Then restart: run_as_root systemctl restart code-server@$USER"
