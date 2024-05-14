{
  pkgs,
  config,
  isNixOs,
  ...
}:
{
  home.packages = with pkgs; [ kitty ];

  xdg.configFile.kitty.source =
    if isNixOs then
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/configs/kitty"
    else
      # TODO: enable after update nix
      ../configs/kitty;
}
