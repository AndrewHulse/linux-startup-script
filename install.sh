#!/bin/bash
#
# Ubuntu Fresh Install Setup Script
# Author: Drew Hulse
# Description: Interactive setup script for fresh Ubuntu installations
#

set -e  # Exit on error

# Parse command line arguments
NON_INTERACTIVE=false
INSTALL_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            NON_INTERACTIVE=true
            INSTALL_ALL=true
            shift
            ;;
        --non-interactive)
            NON_INTERACTIVE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --all              Install all components without prompting"
            echo "  --non-interactive  Skip interactive menu (install default components)"
            echo "  --help, -h         Show this help message"
            echo ""
            echo "Components installed with --all:"
            echo "  1. Basic Packages"
            echo "  2. Git Configuration"
            echo "  3. TMUX Configuration"
            echo "  4. Neofetch (Hyperion)"
            echo "  5. SSH Server"
            echo "  6. Docker"
            echo "  7. Python"
            echo "  8. VS Code Server"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"

# If scripts directory doesn't exist (e.g., piped via curl), download the repo
CLEANUP_REPO=false
if [ ! -d "$SCRIPTS_DIR" ]; then
    log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
    log_info "Scripts directory not found. Downloading from GitHub..."
    TEMP_REPO=$(mktemp -d)
    CLEANUP_REPO=true

    # Clone the repository
    if command -v git &> /dev/null; then
        git clone --quiet https://github.com/AndrewHulse/linux-startup-script.git "$TEMP_REPO" 2>/dev/null
    else
        # If git isn't available, install it first
        if [ "$EUID" -eq 0 ]; then
            apt update -qq && apt install -y git -qq
        else
            sudo apt update -qq && sudo apt install -y git -qq
        fi
        git clone --quiet https://github.com/AndrewHulse/linux-startup-script.git "$TEMP_REPO" 2>/dev/null
    fi

    SCRIPT_DIR="$TEMP_REPO"
    SCRIPTS_DIR="$TEMP_REPO/scripts"
    log_info "Repository downloaded to temporary directory"
fi

# Cleanup function
cleanup() {
    if [ "$CLEANUP_REPO" = true ] && [ -n "$TEMP_REPO" ] && [ -d "$TEMP_REPO" ]; then
        rm -rf "$TEMP_REPO"
    fi
}
trap cleanup EXIT

# Detect if we're running as root
IS_ROOT=false
if [ "$EUID" -eq 0 ]; then
    IS_ROOT=true
fi

# Sudo wrapper - use sudo only if not root and sudo exists
run_as_root() {
    if [ "$IS_ROOT" = true ]; then
        "$@"
    elif command -v sudo &> /dev/null; then
        sudo "$@"
    else
        log_error "This script requires root privileges. Please run as root or install sudo."
        exit 1
    fi
}

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
show_banner() {
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║        Ubuntu Fresh Install Setup Script              ║"
    echo "║        Drew Hulse                                      ║"
    echo "║                                                        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
}

# Check if running on Ubuntu
check_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "Cannot detect OS. This script is designed for Ubuntu."
        exit 1
    fi

    . /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        log_warn "This script is designed for Ubuntu. Detected: $ID"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Interactive menu for selecting components
show_menu() {
    log_info "Select components to install (toggle with number, press ENTER when done):"
    echo ""

    # Component options
    components=(
        "1:Basic Packages (curl, git, vim, etc.):ON"
        "2:Git Configuration (Drew Hulse):ON"
        "3:TMUX Configuration:ON"
        "4:Neofetch (Hyperion branding):ON"
        "5:SSH Server (with key generation):OFF"
        "6:Docker:OFF"
        "7:Python (pip, venv, dev tools):OFF"
        "8:VS Code Server:OFF"
    )

    # Initialize selections
    declare -A selected
    for comp in "${components[@]}"; do
        IFS=':' read -r num desc default <<< "$comp"
        selected[$num]=$default
    done

    while true; do
        clear
        show_banner
        echo "Toggle components to install:"
        echo ""

        for comp in "${components[@]}"; do
            IFS=':' read -r num desc default <<< "$comp"
            checkbox="[ ]"
            if [[ "${selected[$num]}" == "ON" ]]; then
                checkbox="[${GREEN}✓${NC}]"
            fi
            echo -e "  $checkbox $num. $desc"
        done

        echo ""
        echo "  [A] Select All"
        echo "  [N] Select None"
        echo "  [C] Continue with selected options"
        echo "  [Q] Quit"
        echo ""
        read -p "Enter your choice: " choice

        case $choice in
            [1-8])
                if [[ "${selected[$choice]}" == "ON" ]]; then
                    selected[$choice]="OFF"
                else
                    selected[$choice]="ON"
                fi
                ;;
            [Aa])
                for num in {1..8}; do
                    selected[$num]="ON"
                done
                ;;
            [Nn])
                for num in {1..8}; do
                    selected[$num]="OFF"
                done
                ;;
            [Cc])
                break
                ;;
            [Qq])
                log_info "Setup cancelled."
                exit 0
                ;;
        esac
    done

    # Return selected components as space-separated numbers
    SELECTED_COMPONENTS=""
    for num in {1..8}; do
        if [[ "${selected[$num]}" == "ON" ]]; then
            SELECTED_COMPONENTS="$SELECTED_COMPONENTS $num"
        fi
    done
}

# Main installation function
main() {
    show_banner
    check_ubuntu

    # Auto-detect if we're in a non-interactive environment (piped via curl/wget)
    if [[ ! -t 0 ]] && [[ "$NON_INTERACTIVE" == "false" ]]; then
        log_warn "No terminal detected (piped input). Switching to non-interactive mode with defaults."
        log_warn "Use '--all' flag to install all components: curl ... | bash -s -- --all"
        NON_INTERACTIVE=true
    fi

    # Handle non-interactive mode
    if [[ "$NON_INTERACTIVE" == "true" ]]; then
        if [[ "$INSTALL_ALL" == "true" ]]; then
            log_info "Running in non-interactive mode: Installing ALL components"
            SELECTED_COMPONENTS="1 2 3 4 5 6 7 8"
        else
            log_info "Running in non-interactive mode: Installing default components"
            SELECTED_COMPONENTS="1 2 3 4"  # Basic packages, Git, TMUX, Neofetch
        fi
    else
        # Show interactive menu
        show_menu
        clear
        show_banner
    fi

    log_info "Starting installation with selected components..."
    echo ""

    # Update package list first if any packages will be installed
    if [[ $SELECTED_COMPONENTS =~ [1-8] ]]; then
        log_info "Updating package lists..."
        run_as_root apt update
    fi

    # Execute selected components
    for component in $SELECTED_COMPONENTS; do
        case $component in
            1)
                log_info "Installing basic packages..."
                bash "${SCRIPTS_DIR}/packages.sh"
                ;;
            2)
                log_info "Configuring Git..."
                bash "${SCRIPTS_DIR}/git-config.sh"
                ;;
            3)
                log_info "Setting up TMUX configuration..."
                bash "${SCRIPTS_DIR}/tmux.sh"
                ;;
            4)
                log_info "Installing Neofetch configuration..."
                bash "${SCRIPTS_DIR}/neofetch.sh"
                ;;
            5)
                log_info "Setting up SSH server..."
                bash "${SCRIPTS_DIR}/ssh-server.sh"
                ;;
            6)
                log_info "Installing Docker..."
                bash "${SCRIPTS_DIR}/docker.sh"
                ;;
            7)
                log_info "Setting up Python..."
                bash "${SCRIPTS_DIR}/python.sh"
                ;;
            8)
                log_info "Installing VS Code Server..."
                bash "${SCRIPTS_DIR}/vscode-server.sh"
                ;;
        esac
        echo ""
    done

    log_success "Installation complete!"
    echo ""
    log_info "You may need to log out and back in for some changes to take effect."
}

# Run main function
main
