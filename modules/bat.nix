{
  config,
  deps,
  isHm,
  lib,
  ...
}:
let
  cfg = config.modules.bat;

  homeConfig = {
    programs.bat = {
      enable = true;
      config = {
        italic-text = "always";
        theme = "tokyonight_night";
      };
      themes = {
        tokyonight_night = {
          file = "extras/sublime/tokyonight_night.tmTheme";
          src = deps.tokyonight;
        };
      };
    };
  };
in
{
  options = {
    modules.bat = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable bat module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
