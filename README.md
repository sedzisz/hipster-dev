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

The easiest way - just copy-paste this into your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/sedzisz/hipster-dev/main/bootstrap.sh | bash
```

**What this does:**
1. Downloads `bootstrap.sh` via HTTPS (port 443 - standard HTTP)
2. Executes it immediately in bash
3. Bootstrap clones the full repo via SSH (`git@github.com:sedzisz/hipster-dev.git`)
4. Runs the interactive installer
5. Cleans up downloaded files

**Why this works:**
- `curl` downloads the script (uses HTTP/HTTPS - no auth needed)
- `| bash` pipes it to bash for execution
- Inside the script, `git clone` uses SSH (requires your SSH key for GitHub)
- This way you don't need to authenticate curl, only git

### With options

```bash
# Keep downloaded files after installation
curl -fsSL https://raw.githubusercontent.com/sedzisz/hipster-dev/main/bootstrap.sh | bash -s -- --keep

# Show help
curl -fsSL https://raw.githubusercontent.com/sedzisz/hipster-dev/main/bootstrap.sh | bash -s -- --help
```

### Security note

If you're concerned about piping curl to bash (which is generally safe from trusted sources, but...):

```bash
# 1. Download first, inspect, then run:
curl -fsSL https://raw.githubusercontent.com/sedzisz/hipster-dev/main/bootstrap.sh -o bootstrap.sh
cat bootstrap.sh  # Look at what it does
bash bootstrap.sh

# 2. Or clone and run locally (requires SSH key):
git clone git@github.com:sedzisz/hipster-dev.git
cd hipster-dev
./install.sh
```

### Local development

```bash
cd /path/to/hipster-dev
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

## 🏗 Development (SSH)

If you want to contribute or modify locally using SSH:

```bash
# Clone via SSH
git clone git@github.com:sedzisz/hipster-dev.git

# Or add remote via SSH
git remote add origin git@github.com:sedzisz/hipster-dev.git
git push -u origin main
```

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) - The best package manager for macOS
- [Oh My Zsh](https://ohmyz.sh/) - Amazing zsh framework
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Neovim starter config
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder

---

Made with 💜 for developers who love their terminal

