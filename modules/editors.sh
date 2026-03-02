#!/usr/bin/env bash
#
# Editor tools installation module
#

install_neovim() {
    print_section "Neovim Installation"
    
    if check_installed nvim; then
        if confirm "Neovim is already installed. Reinstall?"; then
            print_info "Proceeding with Neovim installation..."
        else
            print_info "Skipping Neovim installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Neovim..."
    
    if brew install neovim; then
        print_success "Neovim installed successfully"
        
        # Install ripgrep for telescope
        print_info "Installing ripgrep (required for Telescope)..."
        brew install ripgrep
        
        # Install fd for better file finding
        print_info "Installing fd..."
        brew install fd
        
        # Install tree-sitter CLI
        print_info "Installing tree-sitter..."
        brew install tree-sitter
        
        # Install lazygit for git integration
        print_info "Installing lazygit..."
        brew install lazygit
        
        # Create config directory
        mkdir -p "$HOME/.config/nvim"
        
        print_success "Neovim setup complete!"
        print_info "Run 'nvim' to start"
        
    else
        print_error "Failed to install Neovim"
        return 1
    fi
}

install_neovim_kickstart() {
    print_section "Neovim Kickstart Installation"
    
    # First ensure Neovim is installed
    if ! check_installed nvim; then
        print_info "Neovim not found. Installing first..."
        install_neovim
    fi
    
    # Backup existing config
    if [[ -d "$HOME/.config/nvim" ]]; then
        if confirm "Existing Neovim config found. Backup and replace with Kickstart?"; then
            backup_config "$HOME/.config/nvim"
            rm -rf "$HOME/.config/nvim"
            rm -rf "$HOME/.local/share/nvim"
            rm -rf "$HOME/.local/state/nvim"
        else
            print_info "Skipping Kickstart installation"
            return 0
        fi
    fi
    
    print_info "Cloning Kickstart.nvim..."
    
    if git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim; then
        print_success "Kickstart.nvim cloned successfully"
        
        # Remove the .git directory to avoid conflicts
        rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/.git
        
        print_info "Installing additional tools..."
        
        # Ensure all dependencies
        brew install ripgrep fd lazygit
        
        # Install a Nerd Font if not present
        if ! fc-list | grep -i "nerd" > /dev/null; then
            print_info "Installing Nerd Font for icons..."
            brew tap homebrew/cask-fonts
            brew install --cask font-meslo-lg-nerd-font
        fi
        
        print_success "Kickstart.nvim setup complete!"
        print_info ""
        print_info "🚀 Next steps:"
        print_info "   1. Run 'nvim'"
        print_info "   2. Wait for plugins to install (automatic)"
        print_info "   3. Restart Neovim"
        print_info "   4. Run ':checkhealth' to verify everything"
        print_info ""
        print_info "📚 Documentation: https://github.com/nvim-lua/kickstart.nvim"
        
    else
        print_error "Failed to clone Kickstart.nvim"
        return 1
    fi
}
