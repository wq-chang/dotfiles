{
  deps,
  dotfilesConfig,
  pkgs,
  ...
}:
let
  zsh-manpage-completion-generator =
    pkgs.callPackage ../packages/zsh-manpage-completion-generator.nix
      {
        inherit deps;
      };
in
{
  home.username = dotfilesConfig.username;
  home.homeDirectory = "/home/${dotfilesConfig.username}";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  programs.bash.enable = true;

  imports = [
    ./${dotfilesConfig.user}/home.nix
    ./${dotfilesConfig.user}/module-configuration.nix
    ../modules
  ];

  home.packages = with pkgs; [
    fd
    nurl
    ripgrep
    wl-clipboard
    zsh-manpage-completion-generator
  ];

  home.sessionPath = [ "$HOME/dotfiles/bin" ];
}
