#!/usr/bin/env bash
#
# Menu system with fzf support and bash fallback
#

# Check if fzf is available
has_fzf() {
    command_exists fzf
}

# Show main menu
show_main_menu() {
    local options=(
        "1 🐳  Containers          - Docker, Podman"
        "2 ☁️   Cloud Tools         - AWS, kubectl"
        "3 🐚  Shell & Terminal    - zsh, fonts, oh-my-zsh"
        "4 🛠   Dev Tools           - pyenv, nvm, sdkman, brew"
        "5 📝  Editors             - Neovim, Kickstart"
        "6 ⚙️   System Utilities    - btop, htop, yazi, lazydocker"
        "7 🚀  Install ALL at once"
        "q 👋  Quit"
    )

    if has_fzf; then
        show_fzf_menu "Select category:" "${options[@]}" | cut -d' ' -f1
    else
        show_bash_menu "Main Menu - Select category:" "${options[@]}" | cut -d' ' -f1
    fi
}

# Show submenu with checkboxes
show_checkbox_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    local selected=()

    if has_fzf; then
        show_fzf_multi_menu "$title" "${options[@]}"
    else
        show_bash_multi_menu "$title" "${options[@]}"
    fi
}

# FZF single select menu
show_fzf_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    
    printf '%s\n' "${options[@]}" | fzf \
        --height=15 \
        --layout=reverse \
        --border \
        --prompt="$title " \
        --header="Use arrow keys to navigate, Enter to select"
}

# FZF multi-select menu
show_fzf_multi_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    
    printf '%s\n' "${options[@]}" | fzf \
        --height=20 \
        --layout=reverse \
        --border \
        --multi \
        --prompt="$title " \
        --header="Tab to select multiple, Enter to confirm"
}

# Bash fallback single select menu
show_bash_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    
    echo -e "\n${BOLD}${BLUE}$title${NC}\n"
    
    select choice in "${options[@]}"; do
        if [[ -n "$choice" ]]; then
            echo "$choice"
            break
        else
            echo -e "${RED}Invalid option${NC}"
        fi
    done
}

# Bash fallback multi-select menu
show_bash_multi_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    local -a selected_indices=()
    
    echo -e "\n${BOLD}${BLUE}$title${NC}"
    echo -e "${CYAN}Enter numbers separated by space (e.g., 1 3 5), or 'a' for all:${NC}\n"
    
    # Show numbered list
    local i=1
    for opt in "${options[@]}"; do
        printf "  %2d) %s\n" "$i" "$opt"
        ((i++))
    done
    
    echo ""
    echo -ne "${YELLOW}Selection: ${NC}"
    read -r input
    
    if [[ "$input" == "a" || "$input" == "all" ]]; then
        # Return all options
        for opt in "${options[@]}"; do
            echo "$opt"
        done
    else
        # Parse selected indices
        for idx in $input; do
            if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#options[@]} )); then
                echo "${options[$((idx-1))]}"
            fi
        done
    fi
}

# Show container tools menu
run_container_menu() {
    print_section "Container Tools"
    
    local options=(
        "docker      - Docker Desktop & CLI"
        "podman      - Podman with docker alias"
    )
    
    local selected
    selected=$(show_checkbox_menu "Select container tools to install:" "${options[@]}")
    
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        case "$item" in
            *docker*) install_docker ;;
            *podman*) install_podman ;;
        esac
    done <<< "$selected"
}

# Show cloud tools menu
run_cloud_menu() {
    print_section "Cloud Tools"
    
    local options=(
        "kubectl     - Kubernetes CLI"
        "k9s         - Kubernetes TUI (interactive k8s dashboard)"
        "aws-cli     - AWS Command Line Interface"
        "aws-vpn     - AWS VPN Client"
        "wireguard   - Modern, fast, secure VPN"
        "openvpn     - OpenVPN + Tunnelblick GUI"
    )
    
    local selected
    selected=$(show_checkbox_menu "Select cloud tools to install:" "${options[@]}")
    
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        case "$item" in
            *kubectl*) install_kubectl ;;
            *k9s*) install_k9s ;;
            *aws-cli*) install_aws_cli ;;
            *aws-vpn*) install_aws_vpn ;;
            *wireguard*) install_wireguard ;;
            *openvpn*) install_openvpn ;;
        esac
    done <<< "$selected"
}

# Show shell tools menu
run_shell_menu() {
    print_section "Shell & Terminal"
    
    local options=(
        "zsh         - Z Shell"
        "oh-my-zsh   - Oh My Zsh framework"
        "nerd-fonts  - Nerd Fonts (Meslo, Hack)"
    )
    
    local selected
    selected=$(show_checkbox_menu "Select shell tools to install:" "${options[@]}")
    
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        case "$item" in
            *zsh*) install_zsh ;;
            *oh-my-zsh*) install_ohmyzsh ;;
            *nerd-fonts*) install_nerd_fonts ;;
        esac
    done <<< "$selected"
}

# Show dev tools menu
run_devtools_menu() {
    print_section "Development Tools"
    
    local options=(
        "brew        - Homebrew package manager"
        "pyenv       - Python version manager"
        "nvm         - Node Version Manager"
        "sdkman      - SDK Manager (Java, Kotlin, etc.)"
    )
    
    local selected
    selected=$(show_checkbox_menu "Select dev tools to install:" "${options[@]}")
    
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        case "$item" in
            *brew*) install_brew ;;
            *pyenv*) install_pyenv ;;
            *nvm*) install_nvm ;;
            *sdkman*) install_sdkman ;;
        esac
    done <<< "$selected"
}

# Show editors menu
run_editors_menu() {
    print_section "Editors"
    
    local options=(
        "neovim      - Neovim editor"
        "kickstart   - Neovim Kickstart configuration"
        "vscode      - Visual Studio Code + extensions"
        "intellij    - IntelliJ IDEA Community Edition"
        "eclipse     - Eclipse IDE for Java Developers"
        "netbeans    - Apache NetBeans IDE"
    )
    
    local selected
    selected=$(show_checkbox_menu "Select editors to install:" "${options[@]}")
    
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        case "$item" in
            *neovim*) install_neovim ;;
            *kickstart*) install_neovim_kickstart ;;
            *vscode*) install_vscode ;;
            *intellij*) install_intellij ;;
            *eclipse*) install_eclipse ;;
            *netbeans*) install_netbeans ;;
        esac
    done <<< "$selected"
}

# Show system utilities menu
run_system_menu() {
    print_section "System Utilities"
    
    local options=(
        "btop        - Modern system monitor (better top)"
        "htop        - Interactive process viewer"
        "dust        - Disk usage analyzer (better du)"
        "duf         - Disk usage/free utility"
        "procs       - Modern replacement for ps"
        "lazydocker  - TUI for Docker management"
        "lazygit     - TUI for Git"
        "yazi        - Blazing fast terminal file manager"
        "zellij      - Terminal workspace/multiplexer"
        "ghostty     - Modern, fast terminal emulator"
        "alacritty   - GPU-accelerated terminal"
        "wezterm     - GPU terminal with lua config"
        "kitty       - Fast, feature-rich terminal"
    )
    
    local selected
    selected=$(show_checkbox_menu "Select system utilities to install:" "${options[@]}")
    
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        case "$item" in
            *btop*) install_btop ;;
            *htop*) install_htop ;;
            *dust*) install_dust ;;
            *duf*) install_duf ;;
            *procs*) install_procs ;;
            *lazydocker*) install_lazydocker ;;
            *lazygit*) install_lazygit ;;
            *yazi*) install_yazi ;;
            *zellij*) install_zellij ;;
            *ghostty*) install_ghostty ;;
            *alacritty*) install_alacritty ;;
            *wezterm*) install_wezterm ;;
            *kitty*) install_kitty ;;
        esac
    done <<< "$selected"
}
