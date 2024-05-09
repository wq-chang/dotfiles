{ pkgs, config, isNixOs, ... }:
{
  home.packages = with pkgs; [
    wezterm
  ];

  xdg.configFile.wezterm.source =
    if isNixOs then
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/configs/wezterm"
    else
    # TODO: enable after update nix
      ../configs/wezterm;
}
