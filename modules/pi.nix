{
  config,
  deps,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.pi;

  homeConfig = {
    home.packages = with pkgs; [
      pi-coding-agent
      nodejs
      bubblewrap
    ];

    home.file = {
      "dotfiles/config/pi/themes/tokyonight_night.json".source =
        "${deps.tokyonight}/extras/pi/tokyonight_night.json";
      ".pi/agent".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/pi";
    };
  };
in
{
  options = {
    modules.pi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable pi module
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
