#!/usr/bin/env bash
#
# Hipster Dev Environment Installer
# Usage: curl -fsSL https://your-domain.com/install.sh | bash
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all modules
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/menu.sh"
source "${SCRIPT_DIR}/modules/container.sh"
source "${SCRIPT_DIR}/modules/cloud.sh"
source "${SCRIPT_DIR}/modules/shell.sh"
source "${SCRIPT_DIR}/modules/devtools.sh"
source "${SCRIPT_DIR}/modules/editors.sh"
source "${SCRIPT_DIR}/modules/system.sh"

# Main categories (simple variables to avoid bash 3.2 compatibility issues)
CATEGORY_1="Containers          - Docker, Podman"
CATEGORY_2="Cloud Tools         - AWS, kubectl"
CATEGORY_3="Shell & Terminal    - zsh, fonts, oh-my-zsh"
CATEGORY_4="Dev Tools           - pyenv, nvm, sdkman, brew"
CATEGORY_5="Editors             - Neovim, Kickstart"
CATEGORY_6="System Utilities    - btop, htop, lazydocker, yazi"
CATEGORY_7="Install ALL at once"
CATEGORY_q="Quit"

show_banner() {
    clear
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
║           🚀 Dev Environment Setup Tool 🚀                    ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}Detected OS: $(detect_os)${NC}\n"
}

main() {
    # Check if running via curl
    if [[ -z "${BASH_SOURCE[0]:-}" ]] || [[ "${BASH_SOURCE[0]}" == "/dev/stdin" ]]; then
        echo -e "${BLUE}Downloading installer...${NC}"
        # In real scenario, this would clone or download the full script
        # For now, assume local execution
    fi

    show_banner

    while true; do
        local choice
        choice=$(show_main_menu)

        case "$choice" in
            1) run_container_menu ;;
            2) run_cloud_menu ;;
            3) run_shell_menu ;;
            4) run_devtools_menu ;;
            5) run_editors_menu ;;
            6) run_system_menu ;;
            7) install_all ;;
            q|Q|quit|exit) 
                echo -e "\n${GREEN}👋 Goodbye!${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac

        echo -e "\n${CYAN}Press Enter to continue...${NC}"
        read -r
        show_banner
    done
}

install_all() {
    echo -e "${YELLOW}🚀 Installing ALL tools...${NC}\n"
    
    # Containers
    install_docker
    install_podman
    
    # Cloud
    install_kubectl
    install_k9s
    install_aws_cli
    install_aws_vpn
    install_wireguard
    install_openvpn
    
    # Shell
    install_brew
    install_zsh
    install_ohmyzsh
    install_nerd_fonts
    
    # Dev Tools
    install_pyenv
    install_nvm
    install_sdkman
    
    # Editors
    install_neovim
    install_neovim_kickstart
    install_vscode
    install_intellij
    install_eclipse
    install_netbeans
    
    # System Utilities
    install_btop
    install_htop
    install_dust
    install_duf
    install_procs
    install_lazydocker
    install_lazygit
    install_yazi
    install_zellij
    
    echo -e "\n${GREEN}✅ All tools installed!${NC}"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
