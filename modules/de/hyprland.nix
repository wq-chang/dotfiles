{ config, pkgs, ... }:
with pkgs;
{
  home.packages = [
    hypridle
    hyprland
  ];

  xdg.configFile.hypr.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/hypr";
}
