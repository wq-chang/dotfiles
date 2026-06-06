{
  config,
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
    ];

    home.file.".pi/agent".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/pi";
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
