{ deps, dotfilesConfig, pkgs, ... }:
let
  zsh-manpage-completion-generator =
    pkgs.callPackage ../../packages/zsh-manpage-completion-generator.nix { inherit deps; };
in
{
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
    awscli2
    fd
    nurl
    ripgrep
    zsh-manpage-completion-generator

    # fedora only
    wl-clipboard
  ];
}
