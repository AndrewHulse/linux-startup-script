# Ubuntu Fresh Install Setup Script

Automated setup script for fresh Ubuntu installations with interactive component selection.

## Features

- **Interactive Menu**: Toggle components on/off before installation
- **Modular Design**: Each component in separate script for easy maintenance
- **Idempotent**: Safe to run multiple times
- **No Authentication Required**: Public repo for easy one-command installation

## Quick Start

### One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/AndrewHulse/ubuntu-setup/main/install.sh | bash
```

Or using wget:

```bash
wget -qO- https://raw.githubusercontent.com/AndrewHulse/ubuntu-setup/main/install.sh | bash
```

### Manual Installation

```bash
git clone https://github.com/AndrewHulse/ubuntu-setup.git
cd ubuntu-setup
chmod +x install.sh
./install.sh
```

## Components

### 1. Basic Packages
Essential command-line tools and utilities:
- curl, wget, git
- vim, nano
- htop, tmux, tree
- build-essential
- And more...

### 2. Git Configuration
Configures Git with:
- Name: Drew Hulse
- Email: Drew.hulse.home@gmail.com
- Default branch: main
- Editor: vim

### 3. TMUX Configuration
Installs custom TMUX configuration from [AndrewHulse/TMUX-Configurations](https://github.com/AndrewHulse/TMUX-Configurations)

### 4. Neofetch (Hyperion Branding)
Installs custom Hyperion Automation neofetch configuration from [AndrewHulse/hyperion-neofetch](https://github.com/AndrewHulse/hyperion-neofetch)

Features:
- Custom Hyperion logo
- Company branding information
- Live weather integration
- Memory bar with percentage

### 5. SSH Server
Sets up OpenSSH server with:
- SSH service installation and activation
- SSH key generation (ed25519)
- Public key display for easy copying to remote machines
- Connection information display

### 6. Docker
Installs Docker Engine with:
- Docker CE (Community Edition)
- Docker Compose plugin
- Docker Buildx plugin
- Adds current user to docker group

### 7. Python
Installs Python development environment:
- Python 3 and pip
- virtualenv support
- Development tools: black, flake8, pylint, pytest

### 8. VS Code Server
Installs code-server (VS Code in the browser):
- Accessible at http://localhost:8080
- Systemd service for automatic startup
- Password authentication

## Directory Structure

```
ubuntu-setup/
├── install.sh              # Main installation script
├── scripts/
│   ├── packages.sh         # Basic packages
│   ├── git-config.sh       # Git configuration
│   ├── tmux.sh             # TMUX setup
│   ├── neofetch.sh         # Neofetch configuration
│   ├── ssh-server.sh       # SSH server setup
│   ├── docker.sh           # Docker installation
│   ├── python.sh           # Python setup
│   └── vscode-server.sh    # VS Code Server
├── dotfiles/               # Configuration files (if needed)
├── README.md               # This file
└── CLAUDE.md               # AI assistant guidance
```

## Usage

1. Run the installation script:
   ```bash
   ./install.sh
   ```

2. Use the interactive menu to select components:
   - Press number keys (1-8) to toggle components
   - Press 'A' to select all
   - Press 'N' to select none
   - Press 'C' to continue with installation
   - Press 'Q' to quit

3. The script will install selected components automatically

## Post-Installation

Some components may require additional steps:

### Docker
Log out and back in for docker group permissions to take effect, then you can run docker commands without sudo.

### SSH Server
Copy the displayed public key to remote machines you want to SSH from:
```bash
# On remote machine, add to ~/.ssh/authorized_keys
```

### VS Code Server
Access at http://localhost:8080 using the password displayed after installation.

## Updating

To update the setup scripts:

```bash
cd ubuntu-setup
git pull
./install.sh
```

## Requirements

- Ubuntu 20.04 or newer (may work on other Debian-based distributions)
- Internet connection
- sudo privileges

## Contributing

This is a personal setup repository. Feel free to fork and customize for your own needs.

## License

Personal use repository.

## Author

Drew Hulse
- Email: Drew.hulse.home@gmail.com
- GitHub: [@AndrewHulse](https://github.com/AndrewHulse)
