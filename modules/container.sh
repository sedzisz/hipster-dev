#!/usr/bin/env bash
#
# Container tools installation module
#

install_docker() {
    print_section "Docker Installation"
    
    if check_installed docker; then
        if confirm "Docker is already installed. Reinstall?"; then
            print_info "Proceeding with Docker installation..."
        else
            print_info "Skipping Docker installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Docker Desktop..."
    
    if brew install --cask docker; then
        print_success "Docker Desktop installed successfully"
        print_info "Please start Docker Desktop from Applications"
        
        # Add docker to zsh completions if using zsh
        if [[ "$SHELL" == */zsh ]]; then
            mkdir -p ~/.zsh/completions
            docker completion zsh > ~/.zsh/completions/_docker 2>/dev/null || true
        fi
    else
        print_error "Failed to install Docker"
        return 1
    fi
}

install_podman() {
    print_section "Podman Installation"
    
    if check_installed podman; then
        if confirm "Podman is already installed. Reinstall?"; then
            print_info "Proceeding with Podman installation..."
        else
            print_info "Skipping Podman installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Podman..."
    
    if brew install podman; then
        print_success "Podman installed successfully"
        
        # Initialize podman machine
        print_info "Initializing Podman machine..."
        podman machine init || true
        
        # Create docker alias
        print_info "Setting up docker alias for Podman..."
        
        local shell_rc
        if [[ "$SHELL" == */zsh ]]; then
            shell_rc="$HOME/.zshrc"
        else
            shell_rc="$HOME/.bashrc"
        fi
        
        # Add alias
        if ! grep -q "alias docker='podman'" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "# Podman as Docker alias" >> "$shell_rc"
            echo "alias docker='podman'" >> "$shell_rc"
            echo "alias docker-compose='podman-compose'" >> "$shell_rc"
            print_success "Docker alias added to $shell_rc"
        fi
        
        # Install podman-compose
        print_info "Installing podman-compose..."
        brew install podman-compose || print_warning "Failed to install podman-compose"
        
        print_success "Podman setup complete!"
        print_info "Run 'podman machine start' to start the VM"
    else
        print_error "Failed to install Podman"
        return 1
    fi
}

install_lazydocker() {
    print_section "LazyDocker Installation"
    
    if check_installed lazydocker; then
        if confirm "LazyDocker is already installed. Reinstall?"; then
            print_info "Proceeding with LazyDocker installation..."
        else
            print_info "Skipping LazyDocker installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing LazyDocker (TUI for Docker)..."
    
    if brew install lazydocker; then
        print_success "LazyDocker installed successfully"
        print_info "Run: lazydocker - manage containers with TUI"
    else
        print_error "Failed to install LazyDocker"
        return 1
    fi
}

install_dive() {
    print_section "Dive Installation"
    
    if check_installed dive; then
        if confirm "Dive is already installed. Reinstall?"; then
            print_info "Proceeding with Dive installation..."
        else
            print_info "Skipping Dive installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Dive (Docker image analyzer)..."
    
    if brew install dive; then
        print_success "Dive installed successfully"
        print_info ""
        print_info "🔍 Dive - A tool for exploring Docker images"
        print_info ""
        print_info "Usage:"
        print_info "  dive <image>     - Analyze a Docker image"
        print_info "  dive build -t myapp .  - Analyze during build"
        print_info ""
        print_info "Keys:"
        print_info "  Tab    - Switch layers/files"
        print_info "  Space  - Filter files"
        print_info "  Ctrl+C - Quit"
    else
        print_error "Failed to install Dive"
        return 1
    fi
}
