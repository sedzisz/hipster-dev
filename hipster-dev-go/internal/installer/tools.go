package installer

// Tool represents a development tool that can be installed
type Tool struct {
	Name        string
	Description string
	Category    string
	CheckCmd    string
	InstallCmd  string
	Cask        bool
}

// GetContainerTools returns container-related tools
func GetContainerTools() []Tool {
	return []Tool{
		{Name: "Docker Desktop", Description: "Docker Desktop & CLI", Category: "containers", Cask: true},
		{Name: "Podman", Description: "Podman with docker alias", Category: "containers", Cask: true},
		{Name: "lazydocker", Description: "TUI for Docker management", Category: "containers"},
		{Name: "dive", Description: "Docker image analyzer", Category: "containers"},
	}
}

// GetCloudTools returns cloud-related tools
func GetCloudTools() []Tool {
	return []Tool{
		{Name: "kubectl", Description: "Kubernetes CLI", Category: "cloud"},
		{Name: "k9s", Description: "Kubernetes TUI dashboard", Category: "cloud"},
		{Name: "AWS CLI", Description: "AWS Command Line Interface", Category: "cloud"},
		{Name: "AWS VPN Client", Description: "AWS VPN Client", Category: "cloud", Cask: true},
		{Name: "WireGuard", Description: "Modern, fast, secure VPN", Category: "cloud", Cask: true},
		{Name: "OpenVPN", Description: "OpenVPN + Tunnelblick", Category: "cloud", Cask: true},
	}
}

// GetShellTools returns shell-related tools
func GetShellTools() []Tool {
	return []Tool{
		{Name: "zsh", Description: "Z Shell", Category: "shell"},
		{Name: "oh-my-zsh", Description: "Oh My Zsh framework", Category: "shell"},
		{Name: "Nerd Fonts", Description: "Meslo, Hack fonts", Category: "shell", Cask: true},
	}
}

// GetDevTools returns development tools
func GetDevTools() []Tool {
	return []Tool{
		{Name: "Homebrew", Description: "Package manager for macOS", Category: "devtools"},
		{Name: "pyenv", Description: "Python version manager", Category: "devtools"},
		{Name: "nvm", Description: "Node Version Manager", Category: "devtools"},
		{Name: "SDKMAN", Description: "SDK Manager (Java, Kotlin)", Category: "devtools"},
	}
}

// GetEditorTools returns editor tools
func GetEditorTools() []Tool {
	return []Tool{
		{Name: "VS Code", Description: "Visual Studio Code", Category: "editors", Cask: true},
		{Name: "IntelliJ IDEA", Description: "JetBrains IDE", Category: "editors", Cask: true},
		{Name: "Neovim", Description: "Vim-based editor", Category: "editors"},
		{Name: "Neovim Kickstart", Description: "Neovim + kickstart config", Category: "editors"},
	}
}

// GetSystemTools returns system utilities
func GetSystemTools() []Tool {
	return []Tool{
		{Name: "btop", Description: "System resource monitor", Category: "system"},
		{Name: "yazi", Description: "Terminal file manager", Category: "system"},
		{Name: "lazygit", Description: "TUI for git", Category: "system"},
		{Name: "zellij", Description: "Terminal multiplexer", Category: "system"},
		{Name: "Ghostty", Description: "Modern terminal emulator", Category: "system", Cask: true},
		{Name: "WezTerm", Description: "GPU-accelerated terminal", Category: "system", Cask: true},
	}
}

// GetAllTools returns all available tools
func GetAllTools() []Tool {
	var all []Tool
	all = append(all, GetContainerTools()...)
	all = append(all, GetCloudTools()...)
	all = append(all, GetShellTools()...)
	all = append(all, GetDevTools()...)
	all = append(all, GetEditorTools()...)
	all = append(all, GetSystemTools()...)
	return all
}
