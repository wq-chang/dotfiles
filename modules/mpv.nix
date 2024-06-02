{
  config,
  deps,
  isHm,
  lib,
  pkgs,
  ...
}:
with pkgs;
let
  cfg = config.modules.mpv;
  simpleHistory = callPackage ../packages/mpv-scripts-simple-history.nix { inherit deps; };

  homeConfig = {
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
      config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/mpv";
  };
in
with lib;
{
  options = {
    modules.mpv = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable mpv module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
