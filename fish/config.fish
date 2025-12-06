if status is-interactive
    # Commands to run in interactive sessions can go here

    # 1. HOMEBREW (Essential)
    eval (/opt/homebrew/bin/brew shellenv)

    # 2. PATHS
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/go/bin
    fish_add_path $HOME/Library/Python/3.9/bin
    fish_add_path /Users/mengkhaiteow/Programming/worldbanc/private/bin
    fish_add_path /opt/homebrew/opt/postgresql@16/bin

    # Bun and Pnpm
    fish_add_path /Users/mengkhaiteow/.bun/bin
    set -gx PNPM_HOME "/Users/mengkhaiteow/Library/pnpm"
    fish_add_path $PNPM_HOME

    # 3. TOOLS
    # Oh-My-Posh (Theme)
    # Note: pipe (|) it to source, which is the Fish way
    # oh-my-posh init fish --config $HOME/.config/ohmyposh/zen.toml | source
    starship init fish | source

    # Zoxide (Smart cd)
    zoxide init fish --cmd cd | source

    # FNM (Fast Node Manager)
    # --use-on-cd: Automatically switches node version when you cd into a folder with .nvmrc
    fnm env --use-on-cd --shell fish | source

    # 4. ALIASES
    alias vi="nvim"
    alias vi-min="NVIM_APPNAME=minimalnvim nvim"
    # --- EZA (LS) ALIASES ---
    # 1. Your Standard View (Clean, Minimal)
    alias ls="eza --icons=always --long --no-filesize --color=always --no-permissions --no-user --group-directories-first"
    # 2. List All (Hidden Files) - "ls -a" replacement
    # Adds --all to your standard view
    alias la="ls --all"
    # 3. List Details (Debug View)
    # When you actually NEED to see permissions, file size, and user (e.g., debugging why a script won't run)
    alias ll="eza --icons=always --long --header --git"
    # 4. Tree View (Context for AI) - Depth 2
    # Ignores node_modules, .git, rust target, and build folders. Perfect for copy-pasting context.
    alias lt="eza --tree --level=2 --icons=always --ignore-glob='node_modules|.git|.next|.DS_Store|target|dist|build'"
    alias ltc="eza --tree --level=2 --ignore-glob='node_modules|.git|.next|.DS_Store|target|dist|build'"
    # 5. Tree View Deep - Depth 3
    # If your project is nested deeper (e.g. src/app/dashboard/...)
    alias lt3="eza --tree --level=3 --icons=always --ignore-glob='node_modules|.git|.next|.DS_Store|target|dist|build'"
    alias c="clear"
    alias zconf="code ~/.config/fish/config.fish" # Quick edit alias
    alias reload="source ~/.config/fish/config.fish"

    # --- GIT ALIASES ---
    alias gs="git status"
    alias ga="git add ."
    alias gc="git commit -m"
    alias gp="git push"
    # --- GIT LOG ALIASES ---
    # 1. Quick Look (Last 15 commits, no scrolling)
    alias gl="git --no-pager log --oneline -n 15"
    # 2. Network View (The "Subway Map" of all branches)
    alias gll="git log --oneline --graph --all"
    # 3. Detailed View (Which files changed?)
    alias gld="git log --stat -n 5"
    # 4. Pretty View (Format with dates and authors)
    alias glp="git log --graph --all --format='%C(yellow)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)'"

    # Pro utils
    alias gun="git restore --staged ."
    alias gnah="git reset --hard HEAD && git clean -fd"
    alias gbr="git branch"
    alias gco="git checkout"
    alias gsw="git switch"

    # 5. LANGUAGE SPECIFICS

    # Java 17
    # Execute the command and set the variable
    set -gx JAVA_HOME (/usr/libexec/java_home -v 17)

    # Bun Setup
    set -gx BUN_INSTALL "$HOME/.bun"
    # Bun completions are usually handled automatically in Fish,
    # but if needed we can source them manually, though rarely required.
end
