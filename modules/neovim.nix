{ config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile.nvim.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/neovim";
}
