package main

import (
	"fmt"
	"os"

	"github.com/charmbracelet/bubbletea"
	"github.com/sedzisz/hipster-dev/internal/ui"
)

func main() {
	p := tea.NewProgram(ui.NewModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
