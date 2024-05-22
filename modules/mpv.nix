{
  config,
  deps,
  pkgs,
  ...
}:
with pkgs;
let
  simpleHistory = callPackage ../packages/mpv-scripts-simple-history.nix { inherit deps; };
in
{
  programs.mpv = {
    enable = true;
    scripts = with mpvScripts; [
      autoload
      uosc
      simpleHistory
      thumbfast
    ];
  };

  xdg.configFile.mpv.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/mpv";
}
