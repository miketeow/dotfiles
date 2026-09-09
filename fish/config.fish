# ~/dotfiles/fish/config.fish
#
# LAYOUT — two zones, and the split matters:
#
#   Top level      → environment + PATH. Runs for EVERY fish, including
#                    non-interactive ones (`fish -c ...`, scripts, and GUI apps
#                    like Zed that capture their environment from a fish subshell).
#   is-interactive → prompt, aliases, and tooling that only makes sense at a
#                    terminal you are typing into.
#
# Putting env vars behind the interactive guard is what caused Zed's Java language
# server to see a different JDK than the terminal did. Keep exports out here.

# ─── 1. HOMEBREW ──────────────────────────────────────────────────────────────
# `brew shellenv fish` emits native fish (it already uses fish_add_path --global).
#
# Run it UNCONDITIONALLY. It used to be guarded on HOMEBREW_PREFIX to skip the
# subprocess in child shells, but that guard was a correctness bug: macOS
# /usr/libexec/path_helper runs in every LOGIN shell and re-hoists /usr/bin and
# friends to the front of PATH, pushing /opt/homebrew/bin behind them. Only
# `brew shellenv` puts Homebrew back in front. With the guard, a nested login
# shell skipped that repair and silently resolved brew-vs-system collisions to
# the system copy - which is why `python3` was Apple's 3.9 in subshells but
# Homebrew's in a fresh terminal. The subprocess costs ~10ms. Not worth it.
/opt/homebrew/bin/brew shellenv fish | source

# ─── 2. ENVIRONMENT ───────────────────────────────────────────────────────────
# No hardcoded major version. /usr/libexec/java_home with no -v returns the newest
# installed JDK, so this never drifts when you add or remove a JDK.
# Guarded so a failed lookup leaves JAVA_HOME unset rather than set to "".
set -l _java_home (/usr/libexec/java_home 2>/dev/null)
if test -n "$_java_home"
    set -gx JAVA_HOME $_java_home
end

set -gx PNPM_HOME "$HOME/Library/pnpm"
set -gx BUN_INSTALL "$HOME/.bun"
set -gx EDITOR "zed --wait"
set -gx VISUAL $EDITOR

# ─── 3. PATH ──────────────────────────────────────────────────────────────────
# -g (global) is deliberate. Without it fish_add_path writes to the UNIVERSAL
# variable fish_user_paths, which is persisted to ~/.config/fish/fish_variables
# and survives edits to this file — deleting a line here would not remove the path.
# With -g, PATH is derived from this file alone. Nonexistent dirs are skipped.
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/go/bin
fish_add_path -g $HOME/.cargo/bin
fish_add_path -g /opt/homebrew/opt/postgresql@18/bin
fish_add_path -g $BUN_INSTALL/bin
fish_add_path -g $PNPM_HOME

# ─── 4. INTERACTIVE ONLY ──────────────────────────────────────────────────────
if status is-interactive
    set -g fish_greeting ""

    # fnm stays here on purpose: `fnm env` creates a per-shell directory under
    # ~/.local/state/fnm_multishells, so running it for every non-interactive
    # shell would litter. Zed captures env from a login+interactive fish, so
    # editor tooling still resolves node correctly.
    starship init fish | source
    zoxide init fish --cmd cd | source
    fnm env --use-on-cd --shell fish | source

    # ─── ALIASES ───
    alias vi="nvim"
    alias vi-min="NVIM_APPNAME=minimalnvim nvim"
    alias c="clear"
    alias cc="claude"

    # Navigation & Maintenance
    alias dot="zed ~/dotfiles"
    alias zconf="zed ~/dotfiles/fish/config.fish"
    # exec fish, not `source`: re-sourcing cannot undo an alias or PATH entry you
    # just deleted, so it can leave stale state behind. exec gives a clean shell.
    alias reload="echo 'Reloading fish config! 🚀'; exec fish"

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
    alias gnah="git reset --hard HEAD && git clean -fd"  # DESTRUCTIVE: discards all uncommitted work
    alias gbr="git branch"
    alias gco="git checkout"
    alias gsw="git switch"

    alias ltcp="tree -I node_modules --dirsfirst | sed 's/\xc2\xa0/ /g' | pbcopy && echo 'Tree copied to clipboard! 🌲'"

end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
