# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Automated Ubuntu fresh install setup script with interactive component selection. Designed for **public access without authentication** to enable one-command installation on new systems.

## Architecture

### Two-Layer Design

1. **Main Script** (`install.sh`): Interactive menu system and orchestration
2. **Component Scripts** (`scripts/*.sh`): Individual installation modules

This modular design allows:
- Easy addition/removal of components
- Independent testing of each component
- Reusable scripts outside the main installer

### Script Execution Flow

```
install.sh
  ↓
show_menu() → user selects components
  ↓
main() → executes selected component scripts
  ↓
scripts/*.sh → individual installations
```

## Essential Commands

### Test the installer interactively
```bash
./install.sh
```

### Test individual components
```bash
bash scripts/packages.sh
bash scripts/git-config.sh
bash scripts/tmux.sh
# etc.
```

### Make scripts executable
```bash
chmod +x install.sh scripts/*.sh
```

## Component Scripts

Each script in `scripts/` must be:
- **Self-contained**: Can run independently
- **Idempotent**: Safe to run multiple times
- **Error-handling**: Uses `set -e` to exit on error
- **Informative**: Prints status messages

### Adding New Components

1. Create new script in `scripts/` directory
2. Add component to `components` array in `install.sh` (around line 67)
3. Add case statement in main installation loop (around line 160)
4. Update README.md with component description
5. Make script executable: `chmod +x scripts/new-script.sh`

### Component Script Template

```bash
#!/bin/bash
#
# Description of what this script does
#

set -e

echo "Installing COMPONENT_NAME..."

# Installation commands here

echo "✓ COMPONENT_NAME installed successfully"
```

## External Dependencies

### GitHub Repositories
- **TMUX Config**: https://github.com/AndrewHulse/TMUX-Configurations
- **Neofetch Config**: https://github.com/AndrewHulse/hyperion-neofetch

Both are cloned to temporary directories, files copied, then cleaned up.

### Package Sources
- **Docker**: Official Docker apt repository
- **VS Code Server**: code-server.dev install script
- **Others**: Ubuntu default apt repositories

## Important Configuration

### Git User Information (git-config.sh)
- Name: "Drew Hulse"
- Email: "Drew.hulse.home@gmail.com"
- Default branch: main

### Neofetch Installation Path (neofetch.sh)
- Config: `~/.config/neofetch/config.conf`
- Logo files: `~/claude/neofetch_wiz/`
- The script updates `image_source` path automatically

### SSH Key (ssh-server.sh)
- Type: ed25519
- Email: "Drew.hulse.home@gmail.com"
- Location: `~/.ssh/id_ed25519`

## Testing Strategy

### Before Committing Changes

1. **Test main script**: Run `./install.sh` with various component selections
2. **Test individual scripts**: Run each modified script independently
3. **Test idempotency**: Run scripts twice to ensure no errors on second run
4. **Check permissions**: Ensure all `.sh` files are executable

### Recommended Test Environment

Use a fresh Ubuntu VM or container to test the complete installation flow:
```bash
docker run -it ubuntu:latest bash
# Then paste the one-command installation
```

## Common Tasks

### Update external repository references
Check these scripts when repos change:
- `scripts/tmux.sh` (line ~19)
- `scripts/neofetch.sh` (line ~23)

### Modify component selection menu
Edit `install.sh`:
- Component list: lines 67-76
- Component execution: lines 151-187

### Change color scheme
Edit color variables at top of `install.sh`:
- RED, GREEN, YELLOW, BLUE, NC (No Color)

## Installation URL Format

The one-command installation uses GitHub raw URLs:
```
https://raw.githubusercontent.com/AndrewHulse/linux-startup-script/main/install.sh
```

**Critical**: Repository must be **public** for this to work without authentication. Keep sensitive information out of this repository.

## Script Robustness

### Error Handling
All scripts use `set -e` to exit immediately on error. Consider this when adding commands that may fail but shouldn't stop execution.

### Backup Strategy
Scripts that modify existing configs create `.backup` files:
- TMUX: `~/.tmux.conf.backup`
- Neofetch: `~/.config/neofetch/config.conf.backup`

### Temporary Files
Use `mktemp -d` for temporary directories, always clean up with `rm -rf` at script end.

## Security Considerations

- No sensitive data (passwords, tokens, private keys) should be committed
- SSH keys are generated locally, not stored in repo
- VS Code Server password is randomly generated during installation
- Repository is public by design for easy installation
