use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::{Backend, CrosstermBackend},
    layout::{Alignment, Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph},
    Frame, Terminal,
};
use serde::Deserialize;
use std::{error::Error, fs, io, path::Path};

// Config structures
#[derive(Debug, Deserialize, Clone)]
struct MenuConfig {
    title: String,
    #[serde(rename = "header_color")]
    header_color: String,
    #[serde(rename = "border_color")]
    border_color: String,
    categories: Vec<Category>,
}

#[derive(Debug, Deserialize, Clone)]
struct Category {
    name: String,
    icon: String,
    items: Vec<MenuItem>,
}

#[derive(Debug, Deserialize, Clone)]
struct MenuItem {
    name: String,
    description: String,
    check: String,
    install: String,
}

// App State
#[derive(Debug)]
enum AppState {
    MainMenu,
    CategoryMenu(usize),
}

#[derive(Debug)]
struct App {
    config: MenuConfig,
    state: AppState,
    list_state: ListState,
}

impl App {
    fn new(config: MenuConfig) -> App {
        let mut list_state = ListState::default();
        list_state.select(Some(0));
        App {
            config,
            state: AppState::MainMenu,
            list_state,
        }
    }

    fn next(&mut self) {
        let count = match &self.state {
            AppState::MainMenu => self.config.categories.len() + 1, // +1 for Quit
            AppState::CategoryMenu(idx) => self.config.categories[*idx].items.len() + 1, // +1 for Back
        };
        
        let i = match self.list_state.selected() {
            Some(i) => {
                if i >= count - 1 {
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
        let count = match &self.state {
            AppState::MainMenu => self.config.categories.len() + 1,
            AppState::CategoryMenu(idx) => self.config.categories[*idx].items.len() + 1,
        };
        
        let i = match self.list_state.selected() {
            Some(i) => {
                if i == 0 {
                    count - 1
                } else {
                    i - 1
                }
            }
            None => 0,
        };
        self.list_state.select(Some(i));
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    // Load config
    let config = load_config()?;

    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create app
    let app = App::new(config);
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
        println!("Error: {:?}", err);
    }

    Ok(())
}

fn load_config() -> Result<MenuConfig, Box<dyn Error>> {
    // Try to load from current directory
    let paths = ["menu.yaml", "config.yaml", "~/.config/hipster-dev/menu.yaml"];
    
    for path in &paths {
        let expanded = shellexpand::tilde(path);
        if Path::new(expanded.as_ref()).exists() {
            let content = fs::read_to_string(expanded.as_ref())?;
            let config: MenuConfig = serde_yaml::from_str(&content)?;
            return Ok(config);
        }
    }
    
    // Fallback to default config
    Err("No config file found. Create menu.yaml".into())
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
                                    if selected == app.config.categories.len() {
                                        return Ok(()); // Quit selected
                                    }
                                    app.state = AppState::CategoryMenu(selected);
                                    app.list_state.select(Some(0));
                                }
                                AppState::CategoryMenu(cat_idx) => {
                                    let cat = &app.config.categories[*cat_idx];
                                    if selected == cat.items.len() {
                                        app.state = AppState::MainMenu;
                                        app.list_state.select(Some(0));
                                    } else {
                                        // Show install command
                                        let item = &cat.items[selected];
                                        // TODO: Actually run the install
                                    }
                                }
                            }
                        }
                    }
                    _ => {}
                }
            }
        }
    }
}

fn parse_color(hex: &str) -> Color {
    if hex.starts_with('#') && hex.len() == 7 {
        let r = u8::from_str_radix(&hex[1..3], 16).unwrap_or(255);
        let g = u8::from_str_radix(&hex[3..5], 16).unwrap_or(255);
        let b = u8::from_str_radix(&hex[5..7], 16).unwrap_or(255);
        return Color::Rgb(r, g, b);
    }
    Color::White
}

fn ui(f: &mut Frame, app: &mut App) {
    let header_color = parse_color(&app.config.header_color);
    let border_color = parse_color(&app.config.border_color);

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
    let header = Paragraph::new(app.config.title.clone())
        .style(Style::default().fg(header_color).add_modifier(Modifier::BOLD))
        .alignment(Alignment::Center);
    f.render_widget(header, chunks[0]);

    // Get items based on state
    let items: Vec<ListItem> = match &app.state {
        AppState::MainMenu => {
            let mut items: Vec<ListItem> = app
                .config
                .categories
                .iter()
                .map(|cat| {
                    ListItem::new(format!("{}  {}", cat.icon, cat.name))
                        .style(Style::default().fg(Color::White))
                })
                .collect();
            items.push(ListItem::new("👋  Quit").style(Style::default().fg(Color::White)));
            items
        }
        AppState::CategoryMenu(idx) => {
            let cat = &app.config.categories[*idx];
            let mut items: Vec<ListItem> = cat
                .items
                .iter()
                .map(|item| {
                    ListItem::new(format!("{}  - {}", item.name, item.description))
                        .style(Style::default().fg(Color::White))
                })
                .collect();
            items.push(ListItem::new("↩  Back").style(Style::default().fg(Color::White)));
            items
        }
    };

    let title = match &app.state {
        AppState::MainMenu => " Select Category ",
        AppState::CategoryMenu(idx) => &format!(" {} ", app.config.categories[*idx].name),
    };

    let list = List::new(items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_style(Style::default().fg(border_color))
                .title(title)
                .title_style(Style::default().fg(border_color).add_modifier(Modifier::BOLD)),
        )
        .highlight_style(
            Style::default()
                .bg(border_color)
                .fg(Color::Rgb(26, 26, 46))
                .add_modifier(Modifier::BOLD),
        )
        .highlight_symbol("▶ ");

    f.render_stateful_widget(list, chunks[1], &mut app.list_state);

    // Help text
    let help = match app.state {
        AppState::MainMenu => "↑/↓ navigate  •  enter select  •  q quit",
        AppState::CategoryMenu(_) => "↑/↓ navigate  •  enter select  •  esc/q back",
    };
    let help_text = Paragraph::new(help)
        .style(Style::default().fg(Color::Rgb(102, 102, 102)))
        .alignment(Alignment::Center);
    f.render_widget(help_text, chunks[2]);
}
