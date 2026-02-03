{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.fonts;

  homeConfig = {
    fonts.fontconfig = {
      enable = true;
    };

    home.packages = with pkgs; [
      jetbrains-mono
      sarasa-gothic
      nerd-fonts.symbols-only
    ];
  };
in
{
  options = {
    modules.fonts = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable fonts module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
