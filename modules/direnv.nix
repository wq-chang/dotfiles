{
  config,
  isHm,
  lib,
  ...
}:
let
  cfg = config.modules.direnv;

  homeConfig = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.hide_env_diff = true;
      };
    };

    home.sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };
in
with lib;
{
  options = {
    modules.direnv = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable direnv module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
