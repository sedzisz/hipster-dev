#!/usr/bin/env bash
#
# System utilities installation module
#

install_btop() {
    print_section "btop Installation"
    
    if check_installed btop; then
        if confirm "btop is already installed. Reinstall?"; then
            print_info "Proceeding with btop installation..."
        else
            print_info "Skipping btop installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing btop..."
    
    if brew install btop; then
        print_success "btop installed successfully"
        
        # Create config directory
        mkdir -p "$HOME/.config/btop"
        
        # Copy themes
        btop --install-config 2>/dev/null || true
        
        print_info "btop is a modern system resource monitor"
        print_info "Run: btop"
    else
        print_error "Failed to install btop"
        return 1
    fi
}

install_htop() {
    print_section "htop Installation"
    
    if check_installed htop; then
        if confirm "htop is already installed. Reinstall?"; then
            print_info "Proceeding with htop installation..."
        else
            print_info "Skipping htop installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing htop..."
    
    if brew install htop; then
        print_success "htop installed successfully"
        print_info "Run: htop"
    else
        print_error "Failed to install htop"
        return 1
    fi
}

install_dust() {
    print_section "dust Installation"
    
    if check_installed dust; then
        if confirm "dust is already installed. Reinstall?"; then
            print_info "Proceeding with dust installation..."
        else
            print_info "Skipping dust installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing dust (du + rust = better disk usage)..."
    
    if brew install dust; then
        print_success "dust installed successfully"
        print_info "Usage: dust - show disk usage in tree view"
        print_info "Run: dust"
    else
        print_error "Failed to install dust"
        return 1
    fi
}

install_duf() {
    print_section "duf Installation"
    
    if check_installed duf; then
        if confirm "duf is already installed. Reinstall?"; then
            print_info "Proceeding with duf installation..."
        else
            print_info "Skipping duf installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing duf (disk usage/free utility)..."
    
    if brew install duf; then
        print_success "duf installed successfully"
        print_info "Run: duf - show disk usage with pretty output"
    else
        print_error "Failed to install duf"
        return 1
    fi
}

install_procs() {
    print_section "procs Installation"
    
    if check_installed procs; then
        if confirm "procs is already installed. Reinstall?"; then
            print_info "Proceeding with procs installation..."
        else
            print_info "Skipping procs installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing procs (modern replacement for ps)..."
    
    if brew install procs; then
        print_success "procs installed successfully"
        print_info "Run: procs - show processes with colors and search"
    else
        print_error "Failed to install procs"
        return 1
    fi
}

install_lazydocker() {
    print_section "lazydocker Installation"
    
    if check_installed lazydocker; then
        if confirm "lazydocker is already installed. Reinstall?"; then
            print_info "Proceeding with lazydocker installation..."
        else
            print_info "Skipping lazydocker installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing lazydocker (TUI for Docker)..."
    
    if brew install lazydocker; then
        print_success "lazydocker installed successfully"
        print_info "Run: lazydocker - manage containers with beautiful TUI"
    else
        print_error "Failed to install lazydocker"
        return 1
    fi
}

install_lazygit() {
    print_section "lazygit Installation"
    
    if check_installed lazygit; then
        if confirm "lazygit is already installed. Reinstall?"; then
            print_info "Proceeding with lazygit installation..."
        else
            print_info "Skipping lazygit installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing lazygit (TUI for Git)..."
    
    if brew install lazygit; then
        print_success "lazygit installed successfully"
        print_info "Run: lazygit - terminal UI for git commands"
    else
        print_error "Failed to install lazygit"
        return 1
    fi
}

install_yazi() {
    print_section "yazi Installation"
    
    if check_installed yazi; then
        if confirm "yazi is already installed. Reinstall?"; then
            print_info "Proceeding with yazi installation..."
        else
            print_info "Skipping yazi installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing yazi (terminal file manager)..."
    
    if brew install yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide; then
        print_success "yazi and dependencies installed successfully"
        
        # Add shell integration
        add_to_shell_config 'export YAZI_CONFIG_HOME="$HOME/.config/yazi"'
        
        print_info "Run: yazi - blazing fast terminal file manager"
        print_info "Keybindings: q=quit, j/k=navigate, Enter=open, Space=select"
    else
        print_error "Failed to install yazi"
        return 1
    fi
}

install_zellij() {
    print_section "zellij Installation"
    
    if check_installed zellij; then
        if confirm "zellij is already installed. Reinstall?"; then
            print_info "Proceeding with zellij installation..."
        else
            print_info "Skipping zellij installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing zellij (terminal workspace)..."
    
    if brew install zellij; then
        print_success "zellij installed successfully"
        print_info "Run: zellij - terminal multiplexer (alternative to tmux)"
    else
        print_error "Failed to install zellij"
        return 1
    fi
}

# Terminal emulators

install_ghostty() {
    print_section "Ghostty Installation"
    
    if [[ -d "/Applications/Ghostty.app" ]]; then
        if confirm "Ghostty is already installed. Reinstall?"; then
            print_info "Proceeding with Ghostty installation..."
        else
            print_info "Skipping Ghostty installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Ghostty (fast, feature-rich terminal)..."
    
    # Ghostty is in homebrew cask
    if brew install --cask ghostty; then
        print_success "Ghostty installed successfully"
        print_info "Ghostty is a modern, fast terminal emulator"
        print_info "Config location: ~/.config/ghostty/config"
    else
        print_error "Failed to install Ghostty"
        return 1
    fi
}

install_alacritty() {
    print_section "Alacritty Installation"
    
    if [[ -d "/Applications/Alacritty.app" ]]; then
        if confirm "Alacritty is already installed. Reinstall?"; then
            print_info "Proceeding with Alacritty installation..."
        else
            print_info "Skipping Alacritty installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Alacritty (GPU-accelerated terminal)..."
    
    if brew install --cask alacritty; then
        print_success "Alacritty installed successfully"
        
        # Create config directory
        mkdir -p "$HOME/.config/alacritty"
        
        # Create basic config if not exists
        if [[ ! -f "$HOME/.config/alacritty/alacritty.toml" ]]; then
            cat > "$HOME/.config/alacritty/alacritty.toml" << 'EOF'
[font]
normal = { family = "MesloLGS NF", style = "Regular" }
size = 13

[window]
opacity = 0.95
padding = { x = 4, y = 4 }

[colors.primary]
background = "#1a1b26"
foreground = "#c0caf5"

[cursor]
style = "Beam"
EOF
            print_info "Created basic config at ~/.config/alacritty/alacritty.toml"
        fi
    else
        print_error "Failed to install Alacritty"
        return 1
    fi
}

install_wezterm() {
    print_section "WezTerm Installation"
    
    if [[ -d "/Applications/WezTerm.app" ]]; then
        if confirm "WezTerm is already installed. Reinstall?"; then
            print_info "Proceeding with WezTerm installation..."
        else
            print_info "Skipping WezTerm installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing WezTerm (GPU-accelerated terminal with lua config)..."
    
    if brew install --cask wezterm; then
        print_success "WezTerm installed successfully"
        
        # Create config directory
        mkdir -p "$HOME/.config/wezterm"
        
        # Create basic config if not exists
        if [[ ! -f "$HOME/.config/wezterm/wezterm.lua" ]]; then
            cat > "$HOME/.config/wezterm/wezterm.lua" << 'EOF'
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font 'MesloLGS NF'
config.font_size = 13
config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 0.95
config.hide_tab_bar_if_only_one_tab = true

return config
EOF
            print_info "Created basic config at ~/.config/wezterm/wezterm.lua"
        fi
    else
        print_error "Failed to install WezTerm"
        return 1
    fi
}

install_kitty() {
    print_section "kitty Installation"
    
    if [[ -d "/Applications/kitty.app" ]]; then
        if confirm "kitty is already installed. Reinstall?"; then
            print_info "Proceeding with kitty installation..."
        else
            print_info "Skipping kitty installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing kitty (fast, feature-rich, GPU-based terminal)..."
    
    if brew install --cask kitty; then
        print_success "kitty installed successfully"
        
        # Create config directory
        mkdir -p "$HOME/.config/kitty"
        
        # Create basic config if not exists
        if [[ ! -f "$HOME/.config/kitty/kitty.conf" ]]; then
            cat > "$HOME/.config/kitty/kitty.conf" << 'EOF'
font_family MesloLGS NF
font_size 13

background_opacity 0.95

# Tokyo Night colors
color0 #1a1b26
color8 #414868

color1 #f7768e
color9 #f7768e

color2 #9ece6a
color10 #9ece6a

color3 #e0af68
color11 #e0af68

color4 #7aa2f7
color12 #7aa2f7

color5 #bb9af7
color13 #bb9af7

color6 #7dcfff
color14 #7dcfff

color7 #c0caf5
color15 #c0caf5

enable_audio_bell no

# Keyboard shortcuts
map cmd+enter new_window_with_cwd
map cmd+t new_tab_with_cwd
EOF
            print_info "Created basic config at ~/.config/kitty/kitty.conf"
        fi
    else
        print_error "Failed to install kitty"
        return 1
    fi
}
