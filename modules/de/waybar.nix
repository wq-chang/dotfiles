{ config, pkgs, ... }:
with pkgs;
{
  home.packages = [ waybar ];

  xdg.configFile.waybar = {
    source = with config; lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/waybar";
  };
}
