{ pkgs, ... }:
with pkgs;
{
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

  home.packages = [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
