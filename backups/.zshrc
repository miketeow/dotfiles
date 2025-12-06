ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#00ffff"
# load completions
autoload -U compinit && compinit
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# oh-my-posh
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh)"
fi

#homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

alias vi="nvim"
alias vi-min="NVIM_APPNAME=minimalnvim nvim"
alias ls="eza --icons=always --long --no-filesize --color=always --no-permissions --no-user"
alias c="clear"

eval "$(zoxide init --cmd cd zsh)"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH=$PATH:$HOME/go/bin
export PATH="$PATH:/Users/mengkhaiteow/Programming/worldbanc/private/bin"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# pnpm
export PNPM_HOME="/Users/mengkhaiteow/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/Users/mengkhaiteow/.bun/_bun" ] && source "/Users/mengkhaiteow/.bun/_bun"
# python pip
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

export JAVA_HOME=$(/usr/libexec/java_home -v 17)
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.4.2
export PATH="/Users/mengkhaiteow/.bun/bin:$PATH"
export PATH=$PATH:$HOME/go/bin
