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
    home.packages = with pkgs; [
      (python3.withPackages (p: with p; [ argcomplete ] ++ cfg.packages p))
    ];
  };
in
with lib;
{
  options = {
    modules.python = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable python module
        '';
      };
      packages = mkOption {
        type = with types; functionTo (listOf package);
        default = p: [ ];
        description = ''
          Packages to be added to Python
        '';
        example = literalExpression ''
          p: with p; [
            debugpy
          ]
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
