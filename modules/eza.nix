{
  config,
  isHm,
  lib,
  ...
}:
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
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable eza module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
