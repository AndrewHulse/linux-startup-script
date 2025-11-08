#!/bin/bash
#
# Configure Git with user information
#

set -e

echo "Configuring Git..."

git config --global user.name "Drew Hulse"
git config --global user.email "Drew.hulse.home@gmail.com"

# Set default branch name to main
git config --global init.defaultBranch main

# Additional useful git configurations
git config --global pull.rebase false
git config --global core.editor "vim"

echo "✓ Git configured successfully"
echo "  Name: Drew Hulse"
echo "  Email: Drew.hulse.home@gmail.com"
