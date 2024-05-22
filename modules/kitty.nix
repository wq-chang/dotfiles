{ pkgs, config, ... }:
with pkgs;
{
  home.packages = [ kitty ];

  xdg.configFile.kitty.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/kitty";
}
