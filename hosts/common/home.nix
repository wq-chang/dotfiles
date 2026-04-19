{
  customPkgs,
  dotfilesConfig,
  homeDirectory,
  homeStateVersion,
  lib,
  pkgs,
  ...
}:
{
  home.username = dotfilesConfig.username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = homeStateVersion;

  programs.home-manager.enable = true;
  programs.bash.enable = true;

  home.packages =
    (with pkgs; [
      fd
      nurl
      ripgrep
    ])
    ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.wl-clipboard ]
    ++ [ customPkgs.zsh-manpage-completion-generator ];

  home.sessionPath = [ "$HOME/dotfiles/bin" ];
}
