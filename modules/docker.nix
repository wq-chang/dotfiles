{
  config,
  dotfilesConfig,
  isHm,
  isNixOs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.docker;

  homeConfig = {
    home.packages = with pkgs; [
      docker
      docker-compose
    ];
  };

  nixOsConfig = {
    virtualisation.docker.enable = true;
    users.users.${dotfilesConfig.username}.extraGroups = [ "docker" ];
  };
in
{
  options = {
    modules.docker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable docker
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    if isHm then
      homeConfig
    else if isNixOs then
      nixOsConfig
    else
      { }
  );
}
