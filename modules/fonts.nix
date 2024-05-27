{ pkgs, ... }:
with pkgs;
{
  fonts.fontconfig.enable = true;
  home.packages = [
    corefonts
    jetbrains-mono
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
