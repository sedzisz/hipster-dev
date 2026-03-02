# 🚀 Hipster Dev Installer

Interactive development environment setup tool for macOS. Install all your favorite dev tools with a beautiful terminal UI.

![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)

## ✨ Features

- 🎯 **Interactive Menu** - Beautiful CLI with `fzf` support (falls back to bash `select`)
- 📦 **Modular** - Install only what you need
- 🎨 **Categories**:
  - 🐳 Containers (Docker, Podman)
  - ☁️ Cloud Tools (AWS CLI, kubectl)
  - 🐚 Shell & Terminal (zsh, oh-my-zsh, Nerd Fonts)
  - 🛠 Dev Tools (Homebrew, pyenv, nvm, SDKMAN)
  - 📝 Editors (Neovim, Kickstart)
- 🔒 **Safe** - Checks for existing installations, creates backups
- 🍎 **macOS Native** - Optimized for macOS (Intel & Apple Silicon)

## 🚀 Quick Start

### One-liner installation (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/sedzisz/hipster-dev/main/bootstrap.sh | bash
```

With options:
```bash
# Keep downloaded files after installation
curl -fsSL https://raw.githubusercontent.com/sedzisz/hipster-dev/main/bootstrap.sh | bash -s -- --keep

# Show help
curl -fsSL https://raw.githubusercontent.com/sedzisz/hipster-dev/main/bootstrap.sh | bash -s -- --help
```

### Or clone and run locally

```bash
git clone https://github.com/yourusername/hipster-dev.git
cd hipster-dev
chmod +x install.sh
./install.sh
```

## 📋 Available Tools

### 🐳 Containers
- [x] **Docker** - Docker Desktop & CLI
- [x] **Podman** - Podman with docker compatibility alias

### ☁️ Cloud
- [x] **kubectl** - Kubernetes CLI
- [x] **AWS CLI** - AWS Command Line Interface
- [x] **AWS VPN Client** - AWS VPN Client for macOS

### 🐚 Shell & Terminal
- [x] **Homebrew** - The missing package manager for macOS
- [x] **zsh** - Z Shell
- [x] **Oh My Zsh** - Zsh framework with plugins
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - fast-syntax-highlighting
  - zsh-completions
  - Powerlevel10k theme
- [x] **Nerd Fonts** - Meslo, Hack, FiraCode, JetBrainsMono

### 🛠 Development Tools
- [x] **pyenv** - Python version manager
- [x] **nvm** - Node Version Manager
- [x] **SDKMAN** - SDK manager for Java, Kotlin, Gradle, Maven

### 📝 Editors
- [x] **Neovim** - Hyperextensible Vim-based text editor
- [x] **Kickstart.nvim** - Neovim starter configuration

## 🎮 Usage

### Main Menu

```
╔═══════════════════════════════════════════════════════════════╗
║                    🚀 Hipster Dev Installer 🚀                ║
╚═══════════════════════════════════════════════════════════════╝

Detected OS: macos

1) Containers           - Docker, Podman
2) Cloud Tools          - AWS, kubectl
3) Shell & Terminal     - zsh, fonts, oh-my-zsh
4) Dev Tools            - pyenv, nvm, sdkman, brew
5) Editors              - Neovim, Kickstart
6) Install ALL at once
q) Quit
```

### Multi-select within categories

Each category shows a checkbox-style menu where you can select multiple tools:

```
━━━ Container Tools ━━━

Select tools to install (Tab to select multiple):
  ☐ Docker Desktop & CLI
  ☐ Podman with docker alias
```

### Using without fzf

If `fzf` is not installed, the script automatically falls back to bash `select`:

```
━━━ Main Menu - Select category: ━━━

1) 🐳  Containers          - Docker, Podman
2) ☁️   Cloud Tools         - AWS, kubectl
3) 🐚  Shell & Terminal    - zsh, fonts, oh-my-zsh
4) 🛠   Dev Tools           - pyenv, nvm, sdkman, brew
5) 📝  Editors             - Neovim, Kickstart
6) 🚀  Install ALL at once
#? 3
```

## 🏗 Project Structure

```
hipster-dev/
├── bootstrap.sh         # Entry point for curl | bash (downloads & runs installer)
├── install.sh           # Main installer with interactive menu
├── lib/
│   ├── utils.sh         # Helper functions (colors, checks, backups)
│   └── menu.sh          # Menu system (fzf + bash fallback)
├── modules/
│   ├── container.sh     # Docker, Podman
│   ├── cloud.sh         # AWS, kubectl
│   ├── shell.sh         # zsh, oh-my-zsh, fonts
│   ├── devtools.sh      # pyenv, nvm, sdkman
│   └── editors.sh       # Neovim, Kickstart
├── README.md
└── LICENSE
```

### How it works

1. **bootstrap.sh** - Lightweight script designed for `curl | bash`. Downloads the full repository to `~/.local/share/hipster-dev/` and runs the main installer.
2. **install.sh** - Full-featured installer with interactive menu system.
3. **lib/** - Shared utilities and menu rendering (supports both `fzf` and pure bash).
4. **modules/** - Installation logic organized by category.

## 🔧 Advanced Usage

### Install specific tool programmatically

```bash
# Source the modules
source lib/utils.sh
source modules/shell.sh

# Install specific tool
install_ohmyzsh
```

### Dry run / Check what's installed

```bash
source lib/utils.sh
check_installed docker
check_installed node
check_installed python
```

### Customizing installations

Each module function can be modified in `modules/*.sh`. All functions follow this pattern:

```bash
install_toolname() {
    print_section "Tool Name Installation"
    
    # Check if already installed
    if check_installed toolname; then
        # Handle reinstall
    fi
    
    # Installation logic
    # ...
    
    print_success "Installation complete!"
}
```

## 🛡️ Safety Features

- ✅ Checks if tool is already installed
- ✅ Creates backups of existing configs (`.zshrc`, nvim config, etc.)
- ✅ Confirms before overwriting
- ✅ Verifies macOS compatibility
- ✅ Non-destructive by default

## 📦 Prerequisites

- macOS 10.15+ (Catalina or newer)
- Internet connection
- curl (pre-installed on macOS)
- Administrative privileges (for some installations)

## 🎨 Recommended Terminal Setup

1. Install **iTerm2** or use **Terminal.app**
2. Use **MesloLGS NF** font (installed by this tool)
3. Set theme to support 256 colors
4. Enjoy your new hipster dev environment! 🚀

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) - The best package manager for macOS
- [Oh My Zsh](https://ohmyz.sh/) - Amazing zsh framework
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Neovim starter config
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder

---

Made with 💜 for developers who love their terminal
