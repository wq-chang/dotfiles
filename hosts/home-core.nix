{
  deps,
  dotfilesConfig,
  pkgs,
  ...
}:
with pkgs;
let
  zsh-manpage-completion-generator = callPackage ../packages/zsh-manpage-completion-generator.nix {
    inherit deps;
  };
in
{
  home.username = dotfilesConfig.username;
  home.homeDirectory = "/home/${dotfilesConfig.username}";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  # xdg.mimeApps.enable = true;

  imports = [
    ./${dotfilesConfig.user}/home.nix
  ];

  home.packages = [
    fd
    (google-chrome.override { commandLineArgs = "--enable-wayland-ime"; })
    (python3.withPackages (
      p: with p; [
        argcomplete
        debugpy
      ]
    ))
    nurl
    ripgrep
    wl-clipboard
    zsh-manpage-completion-generator
  ];

  home.sessionPath = [ "$HOME/dotfiles/bin" ];
}
