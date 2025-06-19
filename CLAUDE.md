# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a personal dotfiles repository containing configuration files for a terminal-based development environment. The configuration uses **git submodules** to manage different components, allowing each major configuration (nvim, tmux) to be maintained as separate repositories while being integrated into a unified dotfiles setup.

### Git Submodules Structure
- `nvim/` - Neovim configuration (submodule)
- `tmux/` - Tmux configuration (submodule)
- Root level contains shell, git, alacritty, and other configurations

The configuration is organized around several key applications:

- **Neovim** - Primary text editor with extensive Lua configuration
- **Tmux** - Terminal multiplexer with plugin ecosystem
- **Alacritty** - Terminal emulator with color theme support
- **Git** - Version control configuration
- **Shell** - Zsh with Oh My Zsh and Starship prompt
- **Starship** - Cross-shell prompt customization

## Setup and Installation

The main setup script is `install.sh` which:
- Installs Oh My Zsh and Starship if not present
- Creates symlinks from the dotfiles directory to standard config locations
- Links configurations to `~/.config/` and home directory

**Important**: When cloning this repository, use `--recurse-submodules` to ensure submodules are initialized:
```bash
git clone --recurse-submodules <repository-url>
```

## Key Configuration Structure

### Neovim Configuration (`nvim/` - submodule)
- **Hybrid Architecture**: Uses both Lua and VimScript (detailed in `nvim/CLAUDE.md`)
- **Local Plugin Management**: All plugins are vendored in `nvim/plugins/` directory
- **No Auto-Updates**: Plugins must be manually updated
- **Entry Point**: `nvim/init.lua` sources VimScript and sets up Lua configuration

### Tmux Configuration (`tmux/` - submodule)
- **Main Config**: `tmux/tmux.conf` with custom prefix (Ctrl+Space)
- **Plugin Manager**: Uses TPM (Tmux Plugin Manager)
- **Plugins**: Located in `tmux/plugins/` directory including:
  - vim-tmux-navigator for seamless navigation
  - catppuccin theme
  - fuzzback for fuzzy search
  - yank for clipboard integration

### Terminal and Shell
- **Alacritty**: Terminal emulator with themes in `alacritty/themes/`
- **Zsh**: Configuration in `.zshrc` using Oh My Zsh with robbyrussell theme
- **Starship**: Prompt configuration in `starship.toml`

### Git Configuration (`git/`)
- User settings and preferences
- Rebase-first workflow with auto-stash
- Nvim as default editor

## Development Workflow

### Installation
```bash
./install.sh
```

### Working with Submodules
```bash
# Update all submodules
git submodule update --remote

# Update specific submodule
git submodule update --remote nvim
git submodule update --remote tmux
```

### Updating Configurations
- Edit configuration files directly in their respective directories
- Changes take effect immediately for most applications
- Tmux: Reload with `Ctrl+Space + r`
- Neovim: Restart or use `:source` commands

### Plugin Management
- **Tmux**: Use TPM commands (`Ctrl+Space + I` to install)
- **Neovim**: See `nvim/CLAUDE.md` for detailed plugin management

## Key Bindings and Features

### Tmux
- Prefix: `Ctrl+Space`
- Window navigation: `Alt+h/l` (previous/next window)
- Session navigation: `Alt+j/k` (next/previous session)
- Fuzzy search: `/` (tmux-fuzzback)
- Finger mode: `j` (tmux-fingers)

### Vim-Tmux Integration
- Seamless navigation between vim splits and tmux panes
- Consistent navigation with `Ctrl+h/j/k/l`

## Architecture Notes

This configuration prioritizes:
- **Modular design**: Git submodules allow independent development of major components
- **Offline capability**: All dependencies are vendored locally
- **Stability**: Manual updates prevent breaking changes
- **Terminal-first workflow**: All tools work in terminal environments
- **Consistent theming**: Catppuccin theme across applications
- **Vim-centric navigation**: Consistent keybindings across tools