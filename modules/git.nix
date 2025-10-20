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
      includes = [ { path = "~/dotfiles/config/git/themes.gitconfig"; } ];
      iniContent = {
        core.pager = lib.mkForce "${pkgs.delta}/bin/delta -s --line-numbers";
      };
      settings = {
        user = {
          name = dotfilesConfig.gitName;
          email = dotfilesConfig.email;
        }
        // lib.optionalAttrs config.modules.gpg.enable {
          signingkey = dotfilesConfig.gpgKey;
        };
        merge.conflictstyle = "diff3";
      }
      // lib.optionalAttrs config.modules.gpg.enable {
        commit.gpgsign = true;
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        features = "tokyonight-night";
        true-color = "always";
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
