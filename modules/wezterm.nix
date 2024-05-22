{ pkgs, config, ... }:
with pkgs;
{
  home.packages = [ wezterm ];

  xdg.configFile.wezterm.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/wezterm";
}
