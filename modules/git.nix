{
  config,
  dotfilesConfig,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.git;

  homeConfig = {
    programs.git = {
      enable = true;
      userName = dotfilesConfig.gitName;
      userEmail = dotfilesConfig.email;
      iniContent = {
        core.pager = lib.mkForce "${pkgs.delta}/bin/delta -s --line-numbers";
      };
      extraConfig = {
        include.path = "~/dotfiles/config/git/themes.gitconfig";
        merge.conflictstyle = "diff3";
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          features = "tokyonight-night";
          true-color = "always";
        };
      };
    };
  };
in
{
  options = {
    modules.git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable git module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
