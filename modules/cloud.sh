#!/usr/bin/env bash
#
# Cloud tools installation module
#

install_kubectl() {
    print_section "kubectl Installation"
    
    if check_installed kubectl; then
        if confirm "kubectl is already installed. Reinstall?"; then
            print_info "Proceeding with kubectl installation..."
        else
            print_info "Skipping kubectl installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing kubectl..."
    
    if brew install kubectl; then
        print_success "kubectl installed successfully"
        
        # Install kubeconform for validation
        print_info "Installing kubeconform..."
        brew install kubeconform || print_warning "Failed to install kubeconform"
        
        # Install kubectx and kubens
        print_info "Installing kubectx and kubens..."
        brew install kubectx || print_warning "Failed to install kubectx"
        
        print_info "kubectl setup complete!"
    else
        print_error "Failed to install kubectl"
        return 1
    fi
}

install_aws_cli() {
    print_section "AWS CLI Installation"
    
    if check_installed aws; then
        if confirm "AWS CLI is already installed. Reinstall?"; then
            print_info "Proceeding with AWS CLI installation..."
        else
            print_info "Skipping AWS CLI installation"
            return 0
        fi
    fi
    
    require_macos
    
    print_info "Installing AWS CLI v2..."
    
    # Download and install AWS CLI
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    
    if sudo installer -pkg AWSCLIV2.pkg -target /; then
        print_success "AWS CLI installed successfully"
        
        # Install additional AWS tools
        print_info "Installing AWS SAM CLI..."
        brew install aws-sam-cli || print_warning "Failed to install SAM CLI"
        
        print_info "Installing AWS CDK..."
        npm install -g aws-cdk || print_warning "Failed to install CDK"
        
        print_info "AWS CLI version:"
        aws --version
    else
        print_error "Failed to install AWS CLI"
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}

install_aws_vpn() {
    print_section "AWS VPN Client Installation"
    
    if [[ -d "/Applications/AWS VPN Client" ]]; then
        if confirm "AWS VPN Client is already installed. Reinstall?"; then
            print_info "Proceeding with AWS VPN Client installation..."
        else
            print_info "Skipping AWS VPN Client installation"
            return 0
        fi
    fi
    
    require_macos
    
    print_info "Downloading AWS VPN Client..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download latest AWS VPN Client
    curl -L "https://d20adtppz83p9s.cloudfront.net/OSX/latest/AWS_VPN_Client.pkg" -o "AWS_VPN_Client.pkg"
    
    if sudo installer -pkg AWS_VPN_Client.pkg -target /; then
        print_success "AWS VPN Client installed successfully"
        print_info "You can find it in Applications"
    else
        print_error "Failed to install AWS VPN Client"
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}

install_wireguard() {
    print_section "WireGuard Installation"
    
    if [[ -d "/Applications/WireGuard.app" ]]; then
        if confirm "WireGuard is already installed. Reinstall?"; then
            print_info "Proceeding with WireGuard installation..."
        else
            print_info "Skipping WireGuard installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing WireGuard (modern, fast, secure VPN)..."
    
    if brew install --cask wireguard; then
        print_success "WireGuard installed successfully"
        print_info ""
        print_info "🔐 WireGuard - next-gen VPN protocol"
        print_info ""
        print_info "Features:"
        print_info "  • Minimal codebase (~4k lines vs 400k+ in OpenVPN/IPsec)"
        print_info "  • Modern cryptography (Curve25519, ChaCha20, Poly1305)"
        print_info "  • High performance"
        print_info "  • Easy configuration"
        print_info ""
        print_info "Config location: ~/.config/wireguard/"
        print_info "GUI app available in Applications"
    else
        print_error "Failed to install WireGuard"
        return 1
    fi
}

install_openvpn() {
    print_section "OpenVPN Installation"
    
    if check_installed openvpn; then
        if confirm "OpenVPN is already installed. Reinstall?"; then
            print_info "Proceeding with OpenVPN installation..."
        else
            print_info "Skipping OpenVPN installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing OpenVPN + Tunnelblick GUI..."
    
    # Install OpenVPN CLI
    if brew install openvpn; then
        print_success "OpenVPN CLI installed"
    fi
    
    # Install Tunnelblick (GUI for macOS)
    if brew install --cask tunnelblick; then
        print_success "Tunnelblick (OpenVPN GUI) installed successfully"
        print_info ""
        print_info "🔒 OpenVPN - industry standard VPN"
        print_info ""
        print_info "Includes:"
        print_info "  • openvpn - CLI client"
        print_info "  • Tunnelblick - macOS GUI"
        print_info ""
        print_info "To connect:"
        print_info "  CLI: sudo openvpn --config client.ovpn"
        print_info "  GUI: Open Tunnelblick from Applications"
    else
        print_error "Failed to install Tunnelblick"
        return 1
    fi
}

install_k9s() {
    print_section "k9s Installation"
    
    if check_installed k9s; then
        if confirm "k9s is already installed. Reinstall?"; then
            print_info "Proceeding with k9s installation..."
        else
            print_info "Skipping k9s installation"
            return 0
        fi
    fi
    
    require_macos
    ensure_brew
    
    print_info "Installing k9s (Kubernetes TUI)..."
    
    if brew install k9s; then
        print_success "k9s installed successfully"
        print_info ""
        print_info "🎯 k9s - Turbocharged Kubernetes CLI"
        print_info ""
        print_info "Quick start:"
        print_info "  k9s                    # Launch k9s with current context"
        print_info "  k9s -n kube-system     # Launch in specific namespace"
        print_info "  k9s --context prod     # Launch with specific context"
        print_info ""
        print_info "Key bindings (vim-style):"
        print_info "  :pod, :deploy, :svc    # Switch views"
        print_info "  /                      # Search/filter"
        print_info "  d                      # Describe resource"
        print_info "  l                      # Show logs"
        print_info "  s                      # Shell into pod"
        print_info "  Ctrl+d                 # Delete resource"
        print_info "  q                      # Quit"
        print_info "  ?                      # Help"
    else
        print_error "Failed to install k9s"
        return 1
    fi
}
