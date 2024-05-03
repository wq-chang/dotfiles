{ config, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # TODO: enable after update nix
  # xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/configs/neovim";
  xdg.configFile.nvim.source = ../configs/neovim;
}
