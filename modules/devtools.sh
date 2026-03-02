#!/usr/bin/env bash
#
# Development tools installation module
#

install_pyenv() {
    print_section "pyenv Installation"
    
    if check_installed pyenv; then
        if confirm "pyenv is already installed. Reinstall?"; then
            print_info "Proceeding with pyenv installation..."
        else
            print_info "Skipping pyenv installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing pyenv..."
    
    if brew install pyenv; then
        print_success "pyenv installed successfully"
        
        # Add to shell config
        local shell_rc
        if [[ "$SHELL" == */zsh ]]; then
            shell_rc="$HOME/.zshrc"
        else
            shell_rc="$HOME/.bashrc"
        fi
        
        # pyenv configuration
        cat >> "$shell_rc" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
        
        print_info "Installing Python build dependencies..."
        brew install openssl readline sqlite3 xz zlib
        
        print_success "pyenv setup complete!"
        print_info "Restart your shell or run: source $shell_rc"
        print_info "Then install Python: pyenv install 3.12.0"
    else
        print_error "Failed to install pyenv"
        return 1
    fi
}

install_nvm() {
    print_section "NVM (Node Version Manager) Installation"
    
    if [[ -d "$HOME/.nvm" ]]; then
        if confirm "NVM is already installed. Reinstall?"; then
            rm -rf "$HOME/.nvm"
        else
            print_info "Skipping NVM installation"
            return 0
        fi
    fi
    
    print_info "Installing NVM..."
    
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
        print_success "NVM installed successfully"
        
        # Source NVM for current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        # Install latest LTS Node
        print_info "Installing latest LTS Node.js..."
        nvm install --lts
        nvm use --lts
        nvm alias default lts/*
        
        print_success "NVM and Node.js setup complete!"
        print_info "Node version: $(node --version)"
        print_info "NPM version: $(npm --version)"
    else
        print_error "Failed to install NVM"
        return 1
    fi
}

install_sdkman() {
    print_section "SDKMAN Installation"
    
    if [[ -d "$HOME/.sdkman" ]]; then
        if confirm "SDKMAN is already installed. Reinstall?"; then
            rm -rf "$HOME/.sdkman"
        else
            print_info "Skipping SDKMAN installation"
            return 0
        fi
    fi
    
    print_info "Installing SDKMAN..."
    
    if curl -s "https://get.sdkman.io" | bash; then
        print_success "SDKMAN installed successfully"
        
        # Source SDKMAN for current session
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
        
        # Install common SDKs
        print_info "Installing Java (Temurin 21)..."
        sdk install java 21.0.2-tem || print_warning "Java installation failed or already installed"
        
        print_info "Installing Kotlin..."
        sdk install kotlin || print_warning "Kotlin installation failed or already installed"
        
        print_info "Installing Gradle..."
        sdk install gradle || print_warning "Gradle installation failed or already installed"
        
        print_info "Installing Maven..."
        sdk install maven || print_warning "Maven installation failed or already installed"
        
        print_success "SDKMAN setup complete!"
        print_info "Run 'sdk list' to see available packages"
    else
        print_error "Failed to install SDKMAN"
        return 1
    fi
}

install_tmux() {
    print_section "Tmux Installation"
    
    if check_installed tmux; then
        if confirm "Tmux is already installed. Reinstall?"; then
            print_info "Proceeding with Tmux installation..."
        else
            print_info "Skipping Tmux installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Tmux..."
    
    if brew install tmux; then
        print_success "Tmux installed successfully"
        
        # Install Tmux Plugin Manager
        print_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || \
            print_warning "TPM already installed"
        
        # Create basic config
        if [[ ! -f "$HOME/.tmux.conf" ]]; then
            cat > "$HOME/.tmux.conf" << 'EOF'
# Tmux configuration
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Mouse support
set -g mouse on

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Initialize TPM
run '~/.tmux/plugins/tpm/tpm'
EOF
            print_success "Created ~/.tmux.conf"
        fi
    else
        print_error "Failed to install Tmux"
        return 1
    fi
}
