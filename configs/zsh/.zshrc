# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# Completion setting
zstyle :compinstall filename $HOME/.zshrc
fpath=(
	$fpath
	$HOME/.zsh_plugins/.cache/completions
)

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit
if command -v aws_completer &>/dev/null; then
	complete -C "$(command -v aws_completer)" aws
fi
# End completion setting

# FZF color
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
--color=fg:#c0caf5,bg:#1a1b26,hl:#ff9e64 \
--color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64 \
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a \
--color=scrollbar:#3b4261,border:#27a1b9"

# ZSH completion color
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# ZSH substring search color
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#7aa2f7,fg=#16161e,bold'

# Add path
path=(
	$path
	$HOME/go/bin
)

# Plugins
plugin_dir=$HOME/.zsh_plugins
# assumes github and slash separated plugin names
github_plugins=(
	romkatv/powerlevel10k
	zsh-users/zsh-autosuggestions
	zsh-users/zsh-completions

	# important sequence
	zsh-users/zsh-syntax-highlighting
	zsh-users/zsh-history-substring-search
)

for plugin in $github_plugins; do
	# clone the plugin from github if it doesn't exist
	if [[ ! -d $plugin_dir/$plugin ]]; then
		mkdir -p $plugin_dir/${plugin%/*}
		git clone --depth 1 --recursive https://github.com/$plugin.git $plugin_dir/$plugin
	fi
	# load the plugin
	for initscript in ${plugin#*/}.zsh ${plugin#*/}.plugin.zsh ${plugin#*/}.sh ${plugin#*/}.zsh-theme; do
		if [[ -f $plugin_dir/$plugin/$initscript ]]; then
			source $plugin_dir/$plugin/$initscript
			break
		fi
	done
done

# Custom Plugins
extra_dir=$HOME/dotfiles/extras/zsh
if [[ -d $extra_dir ]]; then
	for initscript in $extra_dir/*.zsh; do
		if [[ -f $initscript ]]; then
			source $initscript
		fi
	done
fi

# p10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(zoxide init zsh)"

# alias for update zsh plugins
alias zshpull="find $plugin_dir -type d -exec test -e '{}/.git' ';' -print0 | xargs -I {} -0 git -C {} pull"
alias restow="source $HOME/dotfiles/restow.sh"

#load completion module, to fix menuselect not found
zmodload zsh/complist
# keybinding
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey '^H' backward-kill-word

# clean up
unset extra_dir
unset github_plugins
unset initscript
unset plugin
unset plugin_dir
