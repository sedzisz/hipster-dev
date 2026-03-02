#!/usr/bin/env bash
#
# Hipster Dev Installer - Bootstrap Script
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/hipster-dev/main/bootstrap.sh | bash
#
# This script downloads the full installer and runs it
#

set -euo pipefail

# Configuration
REPO_URL="git@github.com:sedzisz/hipster-dev.git"
INSTALL_DIR="$HOME/.local/share/hipster-dev"
BRANCH="main"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██╗  ██╗██╗██████╗ ███████╗████████╗███████╗██████╗        ║
║   ██║  ██║██║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗       ║
║   ███████║██║██████╔╝███████╗   ██║   █████╗  ██████╔╝       ║
║   ██╔══██║██║██╔═══╝ ╚════██║   ██║   ██╔══╝  ██╔══██╗       ║
║   ██║  ██║██║██║     ███████║   ██║   ███████╗██║  ██║       ║
║   ╚═╝  ╚═╝╚═╝╚═╝     ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝       ║
║                                                               ║
║              🚀 Bootstrap Installer 🚀                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unsupported"
    fi
}

check_prerequisites() {
    if [[ "$(detect_os)" != "macos" ]]; then
        print_error "This installer is designed for macOS only"
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed"
        print_info "Install Xcode Command Line Tools: xcode-select --install"
        exit 1
    fi

    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi
}

download_installer() {
    print_info "Downloading Hipster Dev Installer..."
    
    # Create install directory
    mkdir -p "$(dirname "$INSTALL_DIR")"
    
    # Remove old installation if exists
    if [[ -d "$INSTALL_DIR" ]]; then
        print_warning "Found existing installation, updating..."
        rm -rf "$INSTALL_DIR"
    fi
    
    # Clone repository
    if git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR" 2>/dev/null; then
        print_success "Downloaded to $INSTALL_DIR"
    else
        print_error "Failed to download installer"
        print_info "Please check your internet connection and try again"
        exit 1
    fi
}

run_installer() {
    print_info "Starting installer..."
    
    cd "$INSTALL_DIR"
    chmod +x install.sh
    
    # Run the main installer
    ./install.sh "$@"
}

cleanup() {
    if [[ -d "$INSTALL_DIR" ]]; then
        print_info "Cleaning up..."
        rm -rf "$INSTALL_DIR"
    fi
}

main() {
    print_banner
    
    check_prerequisites
    
    # Parse arguments
    local keep_files=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --keep|-k)
                keep_files=true
                shift
                ;;
            --help|-h)
                echo "Usage: curl -fsSL <url> | bash [-s -- [options]]"
                echo ""
                echo "Options:"
                echo "  --keep, -k     Keep downloaded files after installation"
                echo "  --help, -h     Show this help message"
                echo ""
                echo "Example:"
                echo "  curl -fsSL ... | bash"
                echo "  curl -fsSL ... | bash -s -- --keep"
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
    
    download_installer
    run_installer
    
    if [[ "$keep_files" == false ]]; then
        cleanup
    else
        print_info "Installer files kept at: $INSTALL_DIR"
    fi
    
    print_success "Installation complete!"
}

# Run main function
trap 'print_error "Installation interrupted"; cleanup; exit 1' INT TERM
main "$@"
