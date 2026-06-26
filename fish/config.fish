if status is-interactive
    # 1. HOMEBREW (Essential)
    eval (/opt/homebrew/bin/brew shellenv)

    # 2. ENVIRONMENT VARIABLES (Set these before adding to PATH)
    set -gx JAVA_HOME (/usr/libexec/java_home -v 17)
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    set -gx BUN_INSTALL "$HOME/.bun"

    # 3. PATHS
    # fish_add_path is smart: it won't add the same path twice.
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/go/bin
    fish_add_path $HOME/.cargo/bin
    fish_add_path $HOME/Library/Python/3.9/bin
    fish_add_path /opt/homebrew/opt/postgresql@18/bin
    fish_add_path $BUN_INSTALL/bin
    fish_add_path $PNPM_HOME

    # 4. TOOLS INITIALIZATION
    starship init fish | source
    zoxide init fish --cmd cd | source
    fnm env --use-on-cd --shell fish | source

    # 5. ALIASES
    alias vi="nvim"
    alias vi-min="NVIM_APPNAME=minimalnvim nvim"
    alias c="clear"

    # Navigation & Maintenance
    alias dot="zed ~/dotfiles"
    alias zconf="zed ~/dotfiles/fish/config.fish"
    # Added a nice confirmation message to reload
    alias reload="source ~/.config/fish/config.fish; echo 'Successfully reloaded fish config! 🚀'"

    # Eza (ls) replacements
    alias ls="eza --icons=always --long --no-filesize --color=always --no-permissions --no-user --group-directories-first"
    alias la="ls --all"
    alias ll="eza --icons=always --long --header --git"
    alias lt="eza --tree --level=2 --icons=always --ignore-glob='node_modules|.git|.next|.DS_Store|target|dist|build'"
    alias ltc="eza --tree --level=2 --ignore-glob='node_modules|.git|.next|.DS_Store|target|dist|build'"
    alias lt3="eza --tree --level=3 --icons=always --ignore-glob='node_modules|.git|.next|.DS_Store|target|dist|build'"

    # Git aliases
    alias gs="git status"
    alias ga="git add ."
    alias gA="git add -A"  # Adds ALL changes across the entire monorepo
    alias gc="git commit -m"
    alias gp="git push"
    alias gl="git --no-pager log --oneline -n 15"
    alias gll="git log --oneline --graph --all"
    alias gld="git log --stat -n 5"
    alias glp="git log --graph --all --format='%C(yellow)%h%C(reset) -%C(auto)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)'"

    # Git Pro Utils
    alias gun="git restore --staged ."
    alias gnah="git reset --hard HEAD && git clean -fd"
    alias gbr="git branch"
    alias gco="git checkout"
    alias gsw="git switch"

    alias ltcp="tree -I node_modules --dirsfirst | sed 's/\xc2\xa0/ /g' | pbcopy && echo 'Tree copied to clipboard! 🌲'"

end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
