#!/bin/bash
#
# Install Python and development tools
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

echo "Installing Python and development tools..."

# Install Python3 and related packages
run_as_root apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python-is-python3

# Upgrade pip
python3 -m pip install --upgrade pip

# Install common Python development tools
pip3 install --user \
    virtualenv \
    black \
    flake8 \
    pylint \
    pytest

echo "✓ Python installed successfully"
echo ""
echo "  Python version: $(python3 --version)"
echo "  pip version: $(pip3 --version)"
echo ""
echo "  Installed tools:"
echo "    - virtualenv (virtual environment management)"
echo "    - black (code formatter)"
echo "    - flake8 (linter)"
echo "    - pylint (linter)"
echo "    - pytest (testing framework)"
