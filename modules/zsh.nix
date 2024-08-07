{
  config,
  deps,
  dotfilesConfig,
  isHm,
  isNixOs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.zsh;

  completions = pkgs.callPackage ../packages/zsh-completions.nix { inherit deps; };

  homeConfig = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.ignoreDups = true;
      historySubstringSearch = {
        enable = true;
        searchDownKey = "$terminfo[kcud1]";
        searchUpKey = "$terminfo[kcuu1]";
      };
      plugins = [
        {
          name = "p10k";
          file = "powerlevel10k.zsh-theme";
          src = deps.powerlevel10k;
        }
        {
          name = "p10k-config";
          file = ".p10k.zsh";
          src = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/zsh";
        }
        {
          name = "fzf-tab";
          src = deps.fzf-tab;
        }
      ];
      initExtraFirst = ''
        if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      initExtraBeforeCompInit = ''
        fpath+="$HOME/.zsh/plugins/zsh-completions"
        fpath+="$HOME/.zsh/plugins/generated-completions"
      '';
      completionInit = ''
        autoload bashcompinit && bashcompinit
        autoload -Uz compinit && compinit
      '';
      initExtra = ''
        if command -v aws_completer &>/dev/null; then
          complete -C "$(command -v aws_completer)" aws
        fi
        eval "$(register-python-argcomplete $HOME/dotfiles/bin/mdep)"

        bindkey -e
        bindkey '^H' backward-kill-word
        zstyle ':fzf-tab:*' fzf-bindings 'tab:toggle+down' 'shift-tab:toggle+up' 'alt-a:toggle-all'

        export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#7aa2f7,fg=#16161e,bold'
      '';
    };

    home = {
      packages = [ completions ];
      file.".zsh/plugins/zsh-completions".source = completions;
    };
  };

  nixOsConfig = lib.mkIf cfg.defaultShell {
    users.users.${dotfilesConfig.username}.shell = pkgs.zsh;
    programs.zsh.enable = true;
  };
in
{
  options = {
    modules.zsh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable zsh module
        '';
      };
      defaultShell = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Set zsh as default shell
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    if isHm then
      homeConfig
    else if isNixOs then
      nixOsConfig
    else
      { }
  );
}
