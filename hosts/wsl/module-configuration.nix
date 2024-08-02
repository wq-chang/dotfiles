{ ... }:
{
  modules = {
    bat.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fonts.enable = false;
    fzf.enable = true;
    git.enable = true;
    kitty.enable = false;
    lazygit.enable = true;
    neovim.enable = true;
    wezterm.enable = false;
    zsh = {
      enable = true;
      defaultShell = true;
    };
  };
}
