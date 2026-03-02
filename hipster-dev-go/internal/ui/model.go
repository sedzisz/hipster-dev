package ui

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
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
	spinner    spinner.Model
	selected   map[string]bool
	results    []string
	width      int
	height     int
}

// Styles
var (
	titleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(lipgloss.Color("#FF6B6B")).
			MarginLeft(2)

	itemStyle = lipgloss.NewStyle().
			PaddingLeft(4)

	selectedItemStyle = lipgloss.NewStyle().
				PaddingLeft(2).
				Foreground(lipgloss.Color("#4ECDC4"))

	checkMark = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#4ECDC4")).
			Render("✓ ")

	boxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(lipgloss.Color("#4ECDC4")).
			Padding(1, 2)
)

// categoryItem implements list.Item
type categoryItem struct {
	title       string
	description string
}

func (i categoryItem) Title() string       { return i.title }
func (i categoryItem) Description() string { return i.description }
func (i categoryItem) FilterValue() string { return i.title }

// toolItem implements list.Item
type toolItem struct {
	tool installer.Tool
}

func (i toolItem) Title() string       { return i.tool.Name }
func (i toolItem) Description() string { return i.tool.Description }
func (i toolItem) FilterValue() string { return i.tool.Name }

// NewModel creates a new model
func NewModel() Model {
	// Create categories
	cats := []list.Item{
		categoryItem{"🐳  Containers", "Docker, Podman, lazydocker"},
		categoryItem{"☁️  Cloud Tools", "kubectl, AWS CLI, VPNs"},
		categoryItem{"🐚  Shell & Terminal", "zsh, oh-my-zsh, fonts"},
		categoryItem{"🛠   Dev Tools", "pyenv, nvm, sdkman, brew"},
		categoryItem{"📝  Editors", "VS Code, IntelliJ, Neovim"},
		categoryItem{"⚙️  System Utils", "btop, yazi, terminals"},
		categoryItem{"🚀  Install ALL", "Everything at once"},
		categoryItem{"👋  Quit", "Exit installer"},
	}

	// Setup categories list
	delegate := list.NewDefaultDelegate()
	delegate.Styles.NormalTitle = itemStyle
	delegate.Styles.SelectedTitle = selectedItemStyle

	categories := list.New(cats, delegate, 0, 0)
	categories.Title = "Hipster Dev Environment Installer"
	categories.SetShowStatusBar(false)
	categories.SetFilteringEnabled(false)
	categories.Styles.Title = titleStyle

	// Setup spinner
	s := spinner.New()
	s.Spinner = spinner.Dot
	s.Style = lipgloss.NewStyle().Foreground(lipgloss.Color("#4ECDC4"))

	return Model{
		state:      StateMainMenu,
		categories: categories,
		spinner:    s,
		selected:   make(map[string]bool),
	}
}

// Init initializes the model
func (m Model) Init() tea.Cmd {
	return tea.Batch(
		m.spinner.Tick,
	)
}

// Update handles messages
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.categories.SetSize(msg.Width, msg.Height-4)
		if m.tools.Items() != nil {
			m.tools.SetSize(msg.Width, msg.Height-4)
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

	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
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
		return "Goodbye! 👋"
	}
}

func (m Model) viewMainMenu() string {
	header := titleStyle.Render("🎩 Hipster Dev Installer")
	help := "↑/↓: navigate • enter: select • q: quit"
	return fmt.Sprintf("%s\n\n%s\n\n%s",
		header,
		m.categories.View(),
		lipgloss.NewStyle().Foreground(lipgloss.Color("#666")).Render(help))
}

func (m Model) viewCategoryMenu() string {
	header := titleStyle.Render("Select tools to install")
	help := "↑/↓: navigate • space: toggle • enter: install • esc: back"
	return fmt.Sprintf("%s\n\n%s\n\n%s",
		header,
		m.tools.View(),
		lipgloss.NewStyle().Foreground(lipgloss.Color("#666")).Render(help))
}

func (m Model) viewInstalling() string {
	return boxStyle.Render(
		fmt.Sprintf("%s Installing selected tools...\n\n%s",
			m.spinner.View(),
			strings.Join(m.results, "\n")))
}

func (m Model) viewResults() string {
	var sb strings.Builder
	sb.WriteString(titleStyle.Render("✅ Installation Complete!\n\n"))
	for _, r := range m.results {
		sb.WriteString(r + "\n")
	}
	sb.WriteString("\n" + lipgloss.NewStyle().Foreground(lipgloss.Color("#666")).Render("Press q to quit"))
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

		// Check for special items
		switch i.title {
		case "👋  Quit":
			return m, tea.Quit
		case "🚀  Install ALL":
			m.state = StateInstalling
			return m, m.installAll()
		default:
			m.state = StateCategoryMenu
			m.setupToolsList(i.title)
			return m, nil
		}

	case StateCategoryMenu:
		// Get selected tools and install
		m.state = StateInstalling
		return m, m.installSelected()
	}

	return m, nil
}

func (m *Model) setupToolsList(category string) {
	var tools []installer.Tool
	switch category {
	case "🐳  Containers":
		tools = installer.GetContainerTools()
	case "☁️  Cloud Tools":
		tools = installer.GetCloudTools()
	case "🐚  Shell & Terminal":
		tools = installer.GetShellTools()
	case "🛠   Dev Tools":
		tools = installer.GetDevTools()
	case "📝  Editors":
		tools = installer.GetEditorTools()
	case "⚙️  System Utils":
		tools = installer.GetSystemTools()
	}

	items := make([]list.Item, len(tools))
	for i, t := range tools {
		items[i] = toolItem{tool: t}
	}

	delegate := list.NewDefaultDelegate()
	delegate.Styles.NormalTitle = itemStyle
	delegate.Styles.SelectedTitle = selectedItemStyle

	m.tools = list.New(items, delegate, 0, 0)
	m.tools.Title = category
	m.tools.SetShowStatusBar(false)
	m.tools.SetFilteringEnabled(false)
	m.tools.Styles.Title = titleStyle
}

func (m Model) installAll() tea.Cmd {
	return func() tea.Msg {
		// TODO: Implement actual installation
		return nil
	}
}

func (m Model) installSelected() tea.Cmd {
	return func() tea.Msg {
		// TODO: Implement actual installation
		return nil
	}
}
