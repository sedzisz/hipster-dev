#!/usr/bin/env bash
#
# Utility functions for Hipster Dev Installer
#

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            echo "linux-${ID:-unknown}"
        else
            echo "linux-unknown"
        fi
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if tool is already installed
check_installed() {
    local tool="$1"
    if command_exists "$tool"; then
        local version
        version=$("$tool" --version 2>/dev/null | head -n1 || echo "unknown")
        echo -e "${GREEN}✓${NC} $tool (${version})"
        return 0
    else
        echo -e "${RED}✗${NC} $tool"
        return 1
    fi
}

# Print section header
print_section() {
    echo -e "\n${BOLD}${BLUE}━━━ $1 ━━━${NC}\n"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Print error message
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Print info message
print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# Confirm action
confirm() {
    local message="$1"
    local response
    
    echo -ne "${YELLOW}$message [y/N]${NC} "
    read -r response
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Run command with spinner
run_with_spinner() {
    local msg="$1"
    shift
    local cmd="$@"
    
    echo -ne "${CYAN}$msg...${NC} "
    
    if $cmd &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Install Homebrew if not present
ensure_brew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for current session
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

# Get macOS version
get_macos_version() {
    sw_vers -productVersion 2>/dev/null || echo "unknown"
}

# Check if Apple Silicon
is_apple_silicon() {
    [[ "$(uname -m)" == "arm64" ]]
}

# Add to shell config
add_to_shell_config() {
    local line="$1"
    local config_file
    
    if [[ "$SHELL" == */zsh ]]; then
        config_file="$HOME/.zshrc"
    else
        config_file="$HOME/.bashrc"
    fi
    
    if ! grep -q "$line" "$config_file" 2>/dev/null; then
        echo "" >> "$config_file"
        echo "# Added by Hipster Dev Installer" >> "$config_file"
        echo "$line" >> "$config_file"
        print_info "Added to $config_file: $line"
    fi
}

# Backup existing config
backup_config() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        print_info "Backed up $file to $backup"
    fi
}

# Require macOS
require_macos() {
    if [[ "$(detect_os)" != macos* ]]; then
        print_error "This tool is designed for macOS"
        exit 1
    fi
}

# Pause and wait for user
pause() {
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}
