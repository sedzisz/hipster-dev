package ui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/sedzisz/hipster-dev/internal/installer"
)

// AppState represents the current state of the application
type AppState int

const (
	StateMainMenu AppState = iota
	StateCategoryMenu
	StateInstalling
	StateResults
	StateQuit
)

// Model represents the application state
type Model struct {
	state      AppState
	categories list.Model
	tools      list.Model
	selected   map[string]bool
	results    []string
	width      int
	height     int
}

// Colors
const (
	colorPrimary   = "#FF6B6B"
	colorSecondary = "#4ECDC4"
	colorBg        = "#1A1A2E"
	colorText      = "#EAEAEA"
	colorMuted     = "#666666"
)

// Styles
var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color(colorPrimary)).
			MarginLeft(2).
			MarginTop(1).
			Padding(0, 1)

	subtitleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color(colorSecondary)).
			MarginLeft(2)

	boxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color(colorSecondary)).
			Padding(1, 2).
			Margin(1, 2)

	helpStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color(colorMuted)).
			MarginLeft(2)

	selectedStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color(colorSecondary)).
			Bold(true)

	categoryStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color(colorText))
)

// categoryItem implements list.Item
type categoryItem struct {
	title       string
	description string
	icon        string
}

func (i categoryItem) Title() string {
	return fmt.Sprintf("%s  %s", i.icon, i.title)
}
func (i categoryItem) Description() string { return i.description }
func (i categoryItem) FilterValue() string { return i.title }

// toolItem implements list.Item
type toolItem struct {
	tool installer.Tool
}

func (i toolItem) Title() string       { return "  " + i.tool.Name }
func (i toolItem) Description() string { return i.tool.Description }
func (i toolItem) FilterValue() string { return i.tool.Name }

// NewModel creates a new model
func NewModel() Model {
	// Create categories with custom delegate
	delegate := list.NewDefaultDelegate()
	delegate.Styles.NormalTitle = lipgloss.NewStyle().
		Foreground(lipgloss.Color(colorText)).
		Padding(0, 0, 0, 2)
	delegate.Styles.NormalDesc = lipgloss.NewStyle().
		Foreground(lipgloss.Color(colorMuted)).
		Padding(0, 0, 0, 2)
	delegate.Styles.SelectedTitle = lipgloss.NewStyle().
		Border(lipgloss.NormalBorder(), false, false, false, true).
		BorderForeground(lipgloss.Color(colorSecondary)).
		Foreground(lipgloss.Color(colorSecondary)).
		Bold(true).
		Padding(0, 0, 0, 1)
	delegate.Styles.SelectedDesc = lipgloss.NewStyle().
		Foreground(lipgloss.Color(colorSecondary)).
		Padding(0, 0, 0, 2)

	cats := []list.Item{
		categoryItem{"Containers", "Docker, Podman, lazydocker, dive", "🐳"},
		categoryItem{"Cloud Tools", "kubectl, AWS CLI, VPN clients", "☁️"},
		categoryItem{"Shell", "zsh, oh-my-zsh, Nerd Fonts", "🐚"},
		categoryItem{"Dev Tools", "pyenv, nvm, sdkman, Homebrew", "🛠"},
		categoryItem{"Editors", "VS Code, IntelliJ, Neovim", "📝"},
		categoryItem{"System", "btop, yazi, lazygit, terminals", "⚙️"},
		categoryItem{"Install ALL", "Install everything at once", "🚀"},
		categoryItem{"Quit", "Exit the installer", "👋"},
	}

	categories := list.New(cats, delegate, 50, 20)
	categories.SetShowTitle(false)
	categories.SetShowStatusBar(false)
	categories.SetFilteringEnabled(false)

	return Model{
		state:      StateMainMenu,
		categories: categories,
		selected:   make(map[string]bool),
	}
}

// Init initializes the model
func (m Model) Init() tea.Cmd {
	return nil
}

// Update handles messages
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		// Center the list
		listWidth := 60
		if msg.Width < listWidth {
			listWidth = msg.Width - 4
		}
		m.categories.SetSize(listWidth, msg.Height-10)
		if m.tools.Items() != nil {
			m.tools.SetSize(listWidth, msg.Height-10)
		}
		return m, nil

	case tea.KeyMsg:
		switch msg.String() {
		case "q", "ctrl+c":
			if m.state == StateMainMenu {
				return m, tea.Quit
			}
		case "esc":
			if m.state == StateCategoryMenu {
				m.state = StateMainMenu
				return m, nil
			}
		case "enter":
			return m.handleEnter()
		}
	}

	// Update list based on state
	switch m.state {
	case StateMainMenu:
		var cmd tea.Cmd
		m.categories, cmd = m.categories.Update(msg)
		return m, cmd
	case StateCategoryMenu:
		var cmd tea.Cmd
		m.tools, cmd = m.tools.Update(msg)
		return m, cmd
	}

	return m, nil
}

// View renders the UI
func (m Model) View() string {
	switch m.state {
	case StateMainMenu:
		return m.viewMainMenu()
	case StateCategoryMenu:
		return m.viewCategoryMenu()
	case StateInstalling:
		return m.viewInstalling()
	case StateResults:
		return m.viewResults()
	default:
		return ""
	}
}

func (m Model) viewMainMenu() string {
	var sb strings.Builder

	// Header
	sb.WriteString("\n")
	sb.WriteString(titleStyle.Render("🎩  HIPSTER DEV INSTALLER"))
	sb.WriteString("\n")
	sb.WriteString(subtitleStyle.Render("   Modern development environment setup"))
	sb.WriteString("\n\n")

	// Content box
	content := fmt.Sprintf("%s\n\n%s",
		m.categories.View(),
		helpStyle.Render("↑/↓ navigate • enter select • q quit"))

	sb.WriteString(boxStyle.Render(content))

	return sb.String()
}

func (m Model) viewCategoryMenu() string {
	var sb strings.Builder

	sb.WriteString("\n")
	sb.WriteString(titleStyle.Render(m.tools.Title))
	sb.WriteString("\n\n")

	content := fmt.Sprintf("%s\n\n%s",
		m.tools.View(),
		helpStyle.Render("↑/↓ navigate • space toggle • enter install • esc back"))

	sb.WriteString(boxStyle.Render(content))

	return sb.String()
}

func (m Model) viewInstalling() string {
	return boxStyle.Render(
		subtitleStyle.Render("Installing... (not implemented yet)"))
}

func (m Model) viewResults() string {
	var sb strings.Builder
	sb.WriteString(titleStyle.Render("Installation Complete!"))
	sb.WriteString("\n\n")
	for _, r := range m.results {
		sb.WriteString(r + "\n")
	}
	return boxStyle.Render(sb.String())
}

func (m Model) handleEnter() (tea.Model, tea.Cmd) {
	switch m.state {
	case StateMainMenu:
		item := m.categories.SelectedItem()
		if item == nil {
			return m, nil
		}
		i := item.(categoryItem)

		switch i.title {
		case "Quit":
			return m, tea.Quit
		case "Install ALL":
			m.state = StateInstalling
			return m, nil
		default:
			m.state = StateCategoryMenu
			m.setupToolsList(i.title)
			return m, nil
		}

	case StateCategoryMenu:
		m.state = StateInstalling
		return m, nil
	}

	return m, nil
}

func (m *Model) setupToolsList(category string) {
	var tools []installer.Tool
	switch category {
	case "Containers":
		tools = installer.GetContainerTools()
	case "Cloud Tools":
		tools = installer.GetCloudTools()
	case "Shell":
		tools = installer.GetShellTools()
	case "Dev Tools":
		tools = installer.GetDevTools()
	case "Editors":
		tools = installer.GetEditorTools()
	case "System":
		tools = installer.GetSystemTools()
	}

	delegate := list.NewDefaultDelegate()
	delegate.Styles.NormalTitle = lipgloss.NewStyle().
		Foreground(lipgloss.Color(colorText)).
		Padding(0, 0, 0, 2)
	delegate.Styles.NormalDesc = lipgloss.NewStyle().
		Foreground(lipgloss.Color(colorMuted)).
		Padding(0, 0, 0, 2)
	delegate.Styles.SelectedTitle = lipgloss.NewStyle().
		Border(lipgloss.NormalBorder(), false, false, false, true).
		BorderForeground(lipgloss.Color(colorSecondary)).
		Foreground(lipgloss.Color(colorSecondary)).
		Bold(true).
		Padding(0, 0, 0, 1)
	delegate.Styles.SelectedDesc = lipgloss.NewStyle().
		Foreground(lipgloss.Color(colorSecondary)).
		Padding(0, 0, 0, 2)

	items := make([]list.Item, len(tools))
	for i, t := range tools {
		items[i] = toolItem{tool: t}
	}

	m.tools = list.New(items, delegate, 50, 15)
	m.tools.Title = fmt.Sprintf("📦 %s", category)
	m.tools.SetShowTitle(false)
	m.tools.SetShowStatusBar(false)
	m.tools.SetFilteringEnabled(false)
}
