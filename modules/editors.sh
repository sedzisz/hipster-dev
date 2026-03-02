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

install_vscode() {
    print_section "Visual Studio Code Installation"
    
    if check_installed code; then
        if confirm "VS Code is already installed. Reinstall?"; then
            print_info "Proceeding with VS Code installation..."
        else
            print_info "Skipping VS Code installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Visual Studio Code..."
    
    if brew install --cask visual-studio-code; then
        print_success "VS Code installed successfully"
        
        # Install useful extensions
        print_info "Installing recommended extensions..."
        
        local extensions=(
            "eamodio.gitlens"
            "ms-vscode-remote.remote-containers"
            "redhat.vscode-yaml"
            "ms-python.python"
            "dbaeumer.vscode-eslint"
            "esbenp.prettier-vscode"
            "bradlc.vscode-tailwindcss"
            "vscodevim.vim"
            "rust-lang.rust-analyzer"
            "golang.go"
            "hashicorp.terraform"
        )
        
        for ext in "${extensions[@]}"; do
            code --install-extension "$ext" 2>/dev/null || print_warning "Failed to install $ext"
        done
        
        print_success "VS Code setup complete!"
    else
        print_error "Failed to install VS Code"
        return 1
    fi
}

install_intellij() {
    print_section "IntelliJ IDEA Installation"
    
    if [[ -d "/Applications/IntelliJ IDEA.app" ]] || [[ -d "/Applications/IntelliJ IDEA CE.app" ]]; then
        if confirm "IntelliJ IDEA is already installed. Reinstall?"; then
            print_info "Proceeding with IntelliJ IDEA installation..."
        else
            print_info "Skipping IntelliJ IDEA installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing IntelliJ IDEA Community Edition..."
    
    if brew install --cask intellij-idea-ce; then
        print_success "IntelliJ IDEA CE installed successfully"
    else
        print_error "Failed to install IntelliJ IDEA"
        return 1
    fi
}

install_eclipse() {
    print_section "Eclipse Installation"
    
    if [[ -d "/Applications/Eclipse.app" ]]; then
        if confirm "Eclipse is already installed. Reinstall?"; then
            print_info "Proceeding with Eclipse installation..."
        else
            print_info "Skipping Eclipse installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Eclipse IDE for Java Developers..."
    
    if brew install --cask eclipse-java; then
        print_success "Eclipse installed successfully"
        print_info "Alternative versions available: eclipse-jee, eclipse-cpp"
    else
        print_error "Failed to install Eclipse"
        return 1
    fi
}

install_netbeans() {
    print_section "Apache NetBeans Installation"
    
    if [[ -d "/Applications/Apache NetBeans.app" ]] || [[ -d "/Applications/NetBeans.app" ]]; then
        if confirm "NetBeans is already installed. Reinstall?"; then
            print_info "Proceeding with NetBeans installation..."
        else
            print_info "Skipping NetBeans installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Apache NetBeans..."
    
    if brew install --cask apache-netbeans; then
        print_success "Apache NetBeans installed successfully"
        print_info "Supports: Java, PHP, JavaScript, Groovy, C/C++"
    else
        print_error "Failed to install NetBeans"
        return 1
    fi
}
