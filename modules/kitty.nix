{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.kitty;

  homeConfig = {
    home.packages = [ pkgs.kitty ];

    xdg.configFile.kitty.source =
      with config;
      config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/kitty";
  };
in
with lib;
{
  options = {
    modules.kitty = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable kitty module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
