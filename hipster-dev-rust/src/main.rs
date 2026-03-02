use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::{Backend, CrosstermBackend},
    layout::{Alignment, Constraint, Direction, Layout, Margin, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span, Text},
    widgets::{Block, Borders, Clear, List, ListItem, ListState, Paragraph, Wrap},
    Frame, Terminal,
};
use std::{error::Error, io};

#[derive(Debug, Clone)]
struct Category {
    name: &'static str,
    icon: &'static str,
    description: &'static str,
}

const CATEGORIES: &[Category] = &[
    Category { name: "Containers", icon: "🐳", description: "Docker, Podman, lazydocker" },
    Category { name: "Cloud", icon: "☁️", description: "kubectl, AWS CLI, VPN" },
    Category { name: "Shell", icon: "🐚", description: "zsh, oh-my-zsh, fonts" },
    Category { name: "Dev Tools", icon: "🛠", description: "pyenv, nvm, sdkman" },
    Category { name: "Editors", icon: "📝", description: "VS Code, Neovim, IntelliJ" },
    Category { name: "System", icon: "⚙️", description: "btop, yazi, lazygit" },
    Category { name: "Quit", icon: "👋", description: "Exit installer" },
];

#[derive(Debug)]
enum AppState {
    MainMenu,
    CategoryMenu(String),
    Installing(String),
}

#[derive(Debug)]
struct App {
    state: AppState,
    list_state: ListState,
}

impl App {
    fn new() -> App {
        let mut list_state = ListState::default();
        list_state.select(Some(0));
        App {
            state: AppState::MainMenu,
            list_state,
        }
    }

    fn next(&mut self) {
        let i = match self.list_state.selected() {
            Some(i) => {
                if i >= self.get_items().len() - 1 {
                    0
                } else {
                    i + 1
                }
            }
            None => 0,
        };
        self.list_state.select(Some(i));
    }

    fn previous(&mut self) {
        let i = match self.list_state.selected() {
            Some(i) => {
                if i == 0 {
                    self.get_items().len() - 1
                } else {
                    i - 1
                }
            }
            None => 0,
        };
        self.list_state.select(Some(i));
    }

    fn get_items(&self) -> Vec<String> {
        match &self.state {
            AppState::MainMenu => CATEGORIES
                .iter()
                .map(|c| format!("{} {}", c.icon, c.name))
                .collect(),
            AppState::CategoryMenu(cat) => match cat.as_str() {
                "Containers" => vec![
                    "Docker Desktop".to_string(),
                    "Podman".to_string(),
                    "lazydocker".to_string(),
                    "dive".to_string(),
                    "Back".to_string(),
                ],
                "Cloud" => vec![
                    "kubectl".to_string(),
                    "k9s".to_string(),
                    "AWS CLI".to_string(),
                    "WireGuard".to_string(),
                    "Back".to_string(),
                ],
                "Shell" => vec![
                    "zsh".to_string(),
                    "oh-my-zsh".to_string(),
                    "Nerd Fonts".to_string(),
                    "Back".to_string(),
                ],
                _ => vec!["Back".to_string()],
            },
            _ => vec![],
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create app
    let app = App::new();
    let res = run_app(&mut terminal, app);

    // Restore terminal
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    if let Err(err) = res {
        println!("{:?}", err);
    }

    Ok(())
}

fn run_app<B: Backend>(terminal: &mut Terminal<B>, mut app: App) -> io::Result<()> {
    loop {
        terminal.draw(|f| ui(f, &mut app))?;

        if let Event::Key(key) = event::read()? {
            if key.kind == KeyEventKind::Press {
                match key.code {
                    KeyCode::Char('q') => match app.state {
                        AppState::MainMenu => return Ok(()),
                        _ => {
                            app.state = AppState::MainMenu;
                            app.list_state.select(Some(0));
                        }
                    },
                    KeyCode::Esc => match app.state {
                        AppState::CategoryMenu(_) => {
                            app.state = AppState::MainMenu;
                            app.list_state.select(Some(0));
                        }
                        _ => {}
                    },
                    KeyCode::Down => app.next(),
                    KeyCode::Up => app.previous(),
                    KeyCode::Enter => {
                        if let Some(selected) = app.list_state.selected() {
                            match &app.state {
                                AppState::MainMenu => {
                                    if selected == CATEGORIES.len() - 1 {
                                        return Ok(());
                                    }
                                    let cat = CATEGORIES[selected].name.to_string();
                                    app.state = AppState::CategoryMenu(cat);
                                    app.list_state.select(Some(0));
                                }
                                AppState::CategoryMenu(_) => {
                                    let items = app.get_items();
                                    if selected == items.len() - 1 {
                                        app.state = AppState::MainMenu;
                                        app.list_state.select(Some(0));
                                    }
                                }
                                _ => {}
                            }
                        }
                    }
                    _ => {}
                }
            }
        }
    }
}

fn ui(f: &mut Frame, app: &mut App) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .margin(2)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(0),
            Constraint::Length(1),
        ])
        .split(f.area());

    // Header
    let header = Paragraph::new("🎩  HIPSTER DEV INSTALLER")
        .style(Style::default().fg(Color::Rgb(255, 107, 107)).add_modifier(Modifier::BOLD))
        .alignment(Alignment::Center);
    f.render_widget(header, chunks[0]);

    // Main content
    let app_items = app.get_items();
    let items: Vec<ListItem> = app_items
        .iter()
        .map(|i| {
            ListItem::new(i.as_str()).style(Style::default().fg(Color::Rgb(234, 234, 234)))
        })
        .collect();

    let title = match &app.state {
        AppState::MainMenu => " Select Category ".to_string(),
        AppState::CategoryMenu(cat) => format!(" {} ", cat),
        _ => "".to_string(),
    };

    let list = List::new(items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Rgb(78, 205, 196)))
                .title(title)
                .title_style(Style::default().fg(Color::Rgb(78, 205, 196)).add_modifier(Modifier::BOLD)),
        )
        .highlight_style(
            Style::default()
                .bg(Color::Rgb(78, 205, 196))
                .fg(Color::Rgb(26, 26, 46))
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("▶ ");

    f.render_stateful_widget(list, chunks[1], &mut app.list_state);

    // Help text
    let help = match app.state {
        AppState::MainMenu => "↑/↓ navigate  •  enter select  •  q quit",
        AppState::CategoryMenu(_) => "↑/↓ navigate  •  enter select  •  esc/q back",
        _ => "",
    };
    let help_text = Paragraph::new(help)
        .style(Style::default().fg(Color::Rgb(102, 102, 102)))
        .alignment(Alignment::Center);
    f.render_widget(help_text, chunks[2]);
}
