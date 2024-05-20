{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (mpv.override {
      scripts = with mpvScripts; [
        autoload
        modernx
        thumbfast
      ];
    })
  ];

  xdg.configFile.mpv.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/configs/mpv";
}
