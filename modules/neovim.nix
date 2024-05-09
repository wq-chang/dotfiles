{ config, isNixOs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };


  xdg.configFile.nvim.source =
    if isNixOs then
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/configs/neovim"
    else
    # TODO: enable after update nix
      ../configs/neovim;
}
