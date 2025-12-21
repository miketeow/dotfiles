# 🐧 Mike's Dotfiles

A minimalist, high-performance terminal environment built for **Fish Shell**, optimized for macOS (Apple Silicon). This setup focuses on speed, Rust-based modern CLI tools, and a clean "Zen" developer experience.

## 🛠️ Tech Stack

- **Shell:** [Fish](https://fishshell.com/) (The friendly interactive shell)
- **Prompt:** [Starship](https://starship.rs/) (Rust-based, ultra-fast minimal prompt)
- **Node Manager:** [fnm](https://github.com/Schniz/fnm) (Rust-based Fast Node Manager)
- **Navigation:** [zoxide](https://github.com/ajeetdsouza/zoxide) (Smarter `cd` with memory)
- **Listing:** [eza](https://github.com/eza-community/eza) (A modern replacement for `ls`)
- **Editor:** [VS Code](https://code.visualstudio.com/) (via `code` alias)

## 📂 Structure

```text
~/dotfiles
├── fish/
│   └── config.fish     # Main shell script
├── starship.toml       # Prompt styling (Text-based minimalism)
├── .gitignore          # Keeps plugins/junk out of version control
└── backups/            # Archived Zsh and Oh-My-Posh configs
```

## ⌨️ Essential Aliases

### Git (Speed & Workflow)

| Alias  | Command         | Purpose                                |
| :----- | :-------------- | :------------------------------------- |
| `gs`   | `git status`    | Quick status check                     |
| `ga`   | `git add .`     | Stage all changes                      |
| `gc`   | `git commit -m` | Commit with message                    |
| `gl`   | `git log...`    | Quick log (Last 15, no pager)          |
| `gll`  | `git log...`    | Subway map / Graph view                |
| `gnah` | `git reset...`  | Discard all local changes (Dangerous!) |

### Navigation & File Listing

| Alias      | Command      | Purpose                                    |
| :--------- | :----------- | :----------------------------------------- |
| `ls`       | `eza...`     | Minimal list with icons                    |
| `la`       | `eza -a...`  | List including hidden files                |
| `lt`       | `eza --tree` | Project structure for AI context (Level 2) |
| `lt3`      | `eza --tree` | Deep project structure (Level 3)           |
| `cd <dir>` | `zoxide`     | Smart jump to directory                    |

### Maintenance

| Alias    | Purpose                                    |
| :------- | :----------------------------------------- |
| `zconf`  | Edit `config.fish` in VS Code              |
| `dot`    | Open the entire dotfiles folder in VS Code |
| `reload` | Apply changes to the current terminal      |

## 🚀 Installation on a New Machine

1. **Clone the repo:**

   ```bash
   git clone <your-repo-url> ~/dotfiles
   ```

2. **Symlink the configs:**

   ```bash
   ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish
   ln -s ~/dotfiles/starship.toml ~/.config/starship.toml
   ```

3. **Install Homebrew & dependencies:**
   ```bash
   brew install fish starship fnm zoxide eza
   ```
