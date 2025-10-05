{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gpg;

  homeConfig = {
    programs.gpg = {
      enable = true;
    };
    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-tty;
    };
  };
in
{
  options = {
    modules.gpg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable gpg module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
