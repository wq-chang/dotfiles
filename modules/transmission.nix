{
  config,
  isHm,
  isNixOs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.transmission;

  homeConfig = with pkgs; {
    home.packages = [ transmission_4-gtk ];
  };

  nixOsConfig = {
    networking.firewall.allowedTCPPorts = [ 51413 ];
    networking.firewall.allowedUDPPorts = [ 51413 ];
  };
in
with lib;
{
  options = {
    modules.transmission = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable transmission module
        '';
      };
    };
  };

  config = mkIf cfg.enable (
    if isHm then
      homeConfig
    else if isNixOs then
      nixOsConfig
    else
      { }
  );
}
