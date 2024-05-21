{ config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/neovim";
}
