{
  config,
  deps,
  isHm,
  lib,
  ...
}:
let
  cfg = config.modules.eza;

  homeConfig = {
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    xdg.configFile."eza/theme.yml".source = "${deps.tokyonight}/extras/eza/tokyonight.yml";
  };
in
{
  options = {
    modules.eza = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable eza module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
