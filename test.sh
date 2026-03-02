#!/usr/bin/env bash
#
# Test script for Hipster Dev Installer
# Usage: ./test.sh [command]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source modules for testing
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/modules/container.sh"
source "${SCRIPT_DIR}/modules/cloud.sh"
source "${SCRIPT_DIR}/modules/shell.sh"
source "${SCRIPT_DIR}/modules/devtools.sh"
source "${SCRIPT_DIR}/modules/editors.sh"
source "${SCRIPT_DIR}/modules/system.sh"

show_help() {
    echo "Hipster Dev Installer - Test Script"
    echo ""
    echo "Usage:"
    echo "  ./test.sh syntax      - Sprawdź składnię wszystkich plików"
    echo "  ./test.sh check       - Sprawdź co jest już zainstalowane"
    echo "  ./test.sh list        - Lista dostępnych funkcji instalacyjnych"
    echo "  ./test.sh dry-run     - Symulacja (pokazuje co by zainstalował)"
    echo "  ./test.sh install X   - Zainstaluj konkretne narzędzie (np: btop)"
    echo ""
    echo "Przykłady:"
    echo "  ./test.sh syntax"
    echo "  ./test.sh check"
    echo "  ./test.sh install btop"
    echo "  ./test.sh install wireguard"
}

test_syntax() {
    echo -e "${BLUE}Sprawdzanie składni...${NC}"
    local errors=0
    
    for f in install.sh bootstrap.sh lib/*.sh modules/*.sh; do
        if [[ -f "$f" ]]; then
            if bash -n "$f" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} $f"
            else
                echo -e "${RED}✗${NC} $f - BŁĄD SKŁADNI!"
                ((errors++))
            fi
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        echo -e "\n${GREEN}✓ Wszystkie pliki mają poprawną składnię!${NC}"
    else
        echo -e "\n${RED}✗ Znaleziono $errors błędów${NC}"
        exit 1
    fi
}

test_check_installed() {
    echo -e "${BLUE}Sprawdzanie zainstalowanych narzędzi...${NC}\n"
    
    echo -e "${YELLOW}Containers:${NC}"
    check_installed docker || true
    check_installed podman || true
    
    echo -e "\n${YELLOW}Cloud:${NC}"
    check_installed kubectl || true
    check_installed k9s || true
    check_installed aws || true
    
    echo -e "\n${YELLOW}Shell:${NC}"
    check_installed zsh || true
    check_installed brew || true
    
    echo -e "\n${YELLOW}Dev Tools:${NC}"
    check_installed pyenv || true
    check_installed nvm || true
    check_installed sdk || true
    
    echo -e "\n${YELLOW}Editors:${NC}"
    check_installed nvim || true
    check_installed code || true
    
    echo -e "\n${YELLOW}System:${NC}"
    check_installed btop || true
    check_installed htop || true
    check_installed lazydocker || true
    check_installed lazygit || true
    check_installed yazi || true
    check_installed zellij || true
    
    echo -e "\n${YELLOW}Terminale (GUI):${NC}"
    if [[ -d "/Applications/Ghostty.app" ]]; then
        echo -e "${GREEN}✓${NC} Ghostty"
    else
        echo -e "${RED}✗${NC} Ghostty"
    fi
    
    if [[ -d "/Applications/Alacritty.app" ]]; then
        echo -e "${GREEN}✓${NC} Alacritty"
    else
        echo -e "${RED}✗${NC} Alacritty"
    fi
    
    if [[ -d "/Applications/WezTerm.app" ]]; then
        echo -e "${GREEN}✓${NC} WezTerm"
    else
        echo -e "${RED}✗${NC} WezTerm"
    fi
    
    if [[ -d "/Applications/kitty.app" ]]; then
        echo -e "${GREEN}✓${NC} kitty"
    else
        echo -e "${RED}✗${NC} kitty"
    fi
}

list_functions() {
    echo -e "${BLUE}Dostępne funkcje instalacyjne:${NC}\n"
    
    echo -e "${YELLOW}Containers:${NC}"
    echo "  install_docker, install_podman"
    
    echo -e "\n${YELLOW}Cloud:${NC}"
    echo "  install_kubectl, install_k9s"
    echo "  install_aws_cli, install_aws_vpn"
    echo "  install_wireguard, install_openvpn"
    
    echo -e "\n${YELLOW}Shell:${NC}"
    echo "  install_brew, install_zsh"
    echo "  install_ohmyzsh, install_nerd_fonts"
    
    echo -e "\n${YELLOW}Dev Tools:${NC}"
    echo "  install_pyenv, install_nvm, install_sdkman"
    
    echo -e "\n${YELLOW}Editors:${NC}"
    echo "  install_neovim, install_neovim_kickstart"
    
    echo -e "\n${YELLOW}System Utilities:${NC}"
    echo "  install_btop, install_htop, install_dust, install_duf, install_procs"
    echo "  install_lazydocker, install_lazygit, install_yazi, install_zellij"
    echo "  install_ghostty, install_alacritty, install_wezterm, install_kitty"
}

dry_run() {
    echo -e "${YELLOW}=== DRY RUN MODE ===${NC}"
    echo "Pokazuję co by się zainstalowało (bez faktycznej instalacji):\n"
    
    detect_os
    echo "OS: $(detect_os)"
    echo ""
    
    # Sprawdź Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}[WOULD INSTALL]${NC} Homebrew (wymagane dla większości narzędzi)"
    else
        echo -e "${GREEN}[OK]${NC} Homebrew już zainstalowany"
    fi
    
    # Lista narzędzi do sprawdzenia
    local tools=("docker" "kubectl" "aws" "zsh" "nvim" "btop" "yazi")
    
    echo ""
    echo "Status narzędzi:"
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${YELLOW}[MISSING]${NC} $tool"
        fi
    done
}

install_single() {
    local tool="$1"
    
    # Map tool name to function
    case "$tool" in
        docker) install_docker ;;
        podman) install_podman ;;
        kubectl) install_kubectl ;;
        k9s) install_k9s ;;
        aws-cli|aws) install_aws_cli ;;
        aws-vpn) install_aws_vpn ;;
        wireguard) install_wireguard ;;
        openvpn) install_openvpn ;;
        brew) install_brew ;;
        zsh) install_zsh ;;
        ohmyzsh|oh-my-zsh) install_ohmyzsh ;;
        fonts|nerd-fonts) install_nerd_fonts ;;
        pyenv) install_pyenv ;;
        nvm) install_nvm ;;
        sdkman) install_sdkman ;;
        neovim|nvim) install_neovim ;;
        kickstart) install_neovim_kickstart ;;
        btop) install_btop ;;
        htop) install_htop ;;
        dust) install_dust ;;
        duf) install_duf ;;
        procs) install_procs ;;
        lazydocker) install_lazydocker ;;
        lazygit) install_lazygit ;;
        yazi) install_yazi ;;
        zellij) install_zellij ;;
        ghostty) install_ghostty ;;
        alacritty) install_alacritty ;;
        wezterm) install_wezterm ;;
        kitty) install_kitty ;;
        *)
            echo -e "${RED}Nieznane narzędzie: $tool${NC}"
            echo "Użyj: ./test.sh list - aby zobaczyć dostępne"
            exit 1
            ;;
    esac
}

# Main
case "${1:-}" in
    syntax)
        test_syntax
        ;;
    check)
        test_check_installed
        ;;
    list)
        list_functions
        ;;
    dry-run)
        dry_run
        ;;
    install)
        if [[ -z "${2:-}" ]]; then
            echo "Użycie: ./test.sh install <nazwa-narzędzia>"
            echo "Przykład: ./test.sh install btop"
            exit 1
        fi
        install_single "$2"
        ;;
    *)
        show_help
        ;;
esac
