{ pkgs, dotfilesConfig, ... }: {
  home.username = dotfilesConfig.username;
  home.homeDirectory = "/home/${dotfilesConfig.username}";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  imports = [
    ../../modules/bat.nix
    ../../modules/direnv.nix
    ../../modules/eza.nix
    ../../modules/fzf.nix
    ../../modules/git.nix
    ../../modules/lazygit.nix
    ../../modules/neovim.nix
    ../../modules/zoxide.nix
    ../../modules/zsh.nix
  ];

  home.packages = with pkgs; [
    awscli
    fd
    nurl
    ripgrep

    # fedora only
    wl-clipboard
  ];
}
