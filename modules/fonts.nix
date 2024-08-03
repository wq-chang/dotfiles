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
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];
  };
in
with lib;
{
  options = {
    modules.fonts = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable fonts module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
