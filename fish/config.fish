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
    # eza alias
    alias ls="eza --icons=always --long --no-filesize --color=always --no-permissions --no-user --group-directories-first"
    alias c="clear"
    alias zconf="code ~/.config/fish/config.fish" # Quick edit alias
    alias reload="source ~/.config/fish/config.fish"

    # 5. LANGUAGE SPECIFICS

    # Java 17
    # Execute the command and set the variable
    set -gx JAVA_HOME (/usr/libexec/java_home -v 17)

    # Bun Setup
    set -gx BUN_INSTALL "$HOME/.bun"
    # Bun completions are usually handled automatically in Fish,
    # but if needed we can source them manually, though rarely required.
end
