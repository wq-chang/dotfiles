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
      defaultFonts = {
        emoji = [
          "Symbols Nerd Font"
          "Noto Color Emoji"
        ];
        monospace = [
          "Noto Sans Mono"
          "Monospace"
        ];
        sansSerif = [
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK JP"
          "Noto Sans"
        ];
        serif = [
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "Noto Serif"
        ];
      };
    };

    home.packages = with pkgs; [
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
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
