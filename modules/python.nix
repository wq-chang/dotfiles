{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.python;

  homeConfig = {
    home.packages = [ (pkgs.python3.withPackages (p: [ p.argcomplete ] ++ cfg.packages p)) ];
  };
in
{
  options = {
    modules.python = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to enable python module
        '';
      };
      packages = lib.mkOption {
        type = with lib.types; functionTo (listOf package);
        default = p: [ ];
        description = ''
          Packages to be added to Python
        '';
        example = lib.literalExpression ''
          p: with p; [
            debugpy
          ]
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
