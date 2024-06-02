{
  config,
  isHm,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.eza;

  homeConfig = {
    programs.eza = {
      enable = true;
      git = true;
      icons = true;
    };
  };
in
{
  options = {
    modules.eza = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable eza module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
