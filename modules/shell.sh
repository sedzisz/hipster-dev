#!/usr/bin/env bash
#
# Shell and terminal tools installation module
#

install_brew() {
    print_section "Homebrew Installation"
    
    if check_installed brew; then
        print_info "Homebrew is already installed"
        print_info "Updating Homebrew..."
        brew update
        print_success "Homebrew updated"
        return 0
    fi
    
    require_macos
    
    print_info "Installing Homebrew..."
    
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        print_success "Homebrew installed successfully"
        
        # Add to PATH
        if is_apple_silicon; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Install essential formulae
        print_info "Installing essential packages..."
        brew install git curl wget jq yq fzf ripgrep fd bat eza zoxide
        
        print_success "Homebrew setup complete!"
    else
        print_error "Failed to install Homebrew"
        return 1
    fi
}

install_zsh() {
    print_section "Zsh Installation"
    
    if check_installed zsh; then
        print_info "Zsh is already installed"
        if [[ "$SHELL" != */zsh ]]; then
            print_info "Changing default shell to zsh..."
            chsh -s $(which zsh)
            print_success "Default shell changed to zsh"
        fi
        return 0
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing Zsh..."
    
    if brew install zsh; then
        print_success "Zsh installed successfully"
        
        # Change default shell
        print_info "Changing default shell to zsh..."
        if sudo chsh -s $(which zsh) "$USER"; then
            print_success "Default shell changed to zsh"
        else
            print_warning "Could not change default shell automatically"
            print_info "Run: chsh -s $(which zsh)"
        fi
    else
        print_error "Failed to install Zsh"
        return 1
    fi
}

install_ohmyzsh() {
    print_section "Oh My Zsh Installation"
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        if confirm "Oh My Zsh is already installed. Reinstall?"; then
            rm -rf "$HOME/.oh-my-zsh"
        else
            print_info "Skipping Oh My Zsh installation"
            return 0
        fi
    fi
    
    print_info "Installing Oh My Zsh..."
    
    # Backup existing .zshrc
    backup_config "$HOME/.zshrc"
    
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        print_success "Oh My Zsh installed successfully"
        
        # Install useful plugins
        print_info "Installing plugins..."
        
        # zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || \
            print_warning "zsh-autosuggestions already installed"
        
        # zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || \
            print_warning "zsh-syntax-highlighting already installed"
        
        # fast-syntax-highlighting
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting" 2>/dev/null || \
            print_warning "fast-syntax-highlighting already installed"
        
        # zsh-completions
        git clone https://github.com/zsh-users/zsh-completions \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions" 2>/dev/null || \
            print_warning "zsh-completions already installed"
        
        # Powerlevel10k theme
        print_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 2>/dev/null || \
            print_warning "Powerlevel10k already installed"
        
        # Enable plugins in .zshrc
        sed -i.bak 's/^plugins=(git)/plugins=(git docker kubectl aws zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-completions)/' "$HOME/.zshrc"
        
        # Set theme
        sed -i.bak 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        
        print_success "Oh My Zsh setup complete!"
        print_info "Run 'source ~/.zshrc' or restart your terminal"
    else
        print_error "Failed to install Oh My Zsh"
        return 1
    fi
}

install_nerd_fonts() {
    print_section "Nerd Fonts Installation"
    
    require_macos
    ensure_brew
    
    print_info "Installing Nerd Fonts..."
    
    local fonts=(
        "font-meslo-lg-nerd-font"
        "font-hack-nerd-font"
        "font-fira-code-nerd-font"
        "font-jetbrains-mono-nerd-font"
    )
    
    for font in "${fonts[@]}"; do
        print_info "Installing $font..."
        brew install --cask "$font" 2>/dev/null || print_warning "Failed to install $font (may already be installed)"
    done
    
    print_success "Nerd Fonts installed!"
    print_info "Please configure your terminal to use one of these fonts:"
    print_info "  - MesloLGS NF (recommended for Powerlevel10k)"
    print_info "  - Hack Nerd Font"
    print_info "  - FiraCode Nerd Font"
    print_info "  - JetBrainsMono Nerd Font"
}
