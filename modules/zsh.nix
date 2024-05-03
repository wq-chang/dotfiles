{ deps, pkgs, ... }:
let
  completions = import ./utils/zsh-completions.nix { inherit deps pkgs; };
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.ignoreDups = true;
    historySubstringSearch.enable = true;
    plugins = with pkgs; [
      {
        name = "p10k";
        file = "powerlevel10k.zsh-theme";
        src = with deps.powerlevel10k; pkgs.fetchgit {
          inherit url branchName rev hash;
        };
      }
      {
        name = "p10k-config";
        file = ".p10k.zsh";
        # TODO: change to mkOutOfStoreSymlink
        src = ../configs/zsh;
      }
      {
        name = "fzf-tab";
        src = with deps.fzf-tab; pkgs.fetchgit {
          inherit url branchName rev hash;
        };
      }
    ];
    completionInit = ''
      autoload bashcompinit && bashcompinit
      autoload -Uz compinit && compinit
    '';
    initExtraFirst = ''
      if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      	source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    initExtraBeforeCompInit = ''
      fpath+="$HOME/.zsh/plugins/zsh-completions"
    '';
    initExtra = ''
      if command -v aws_completer &>/dev/null; then
      	complete -C "$(command -v aws_completer)" aws
      fi
      bindkey -e
      bindkey '^H' backward-kill-word
      zstyle ':fzf-tab:*' fzf-bindings 'tab:toggle+down' 'shift-tab:toggle+up' 'alt-a:toggle-all'
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#7aa2f7,fg=#16161e,bold'
      export DIRENV_LOG_FORMAT=
    '';
  };

  home.file.".zsh/plugins/zsh-completions".source = completions.out;
}
