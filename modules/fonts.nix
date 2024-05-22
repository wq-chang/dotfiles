{ pkgs, ... }:
with pkgs;
{
  fonts.fontconfig.enable = true;
  home.packages = [
    jetbrains-mono
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
