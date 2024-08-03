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

    xdg.configFile.kitty.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/kitty";
  };
in
{
  options = {
    modules.kitty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable kitty module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
