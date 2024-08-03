{
  config,
  deps,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.wezterm;

  homeConfig = {
    home.packages = [ pkgs.wezterm ];

    xdg.configFile.wezterm.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/wezterm";

    home.file.".local/share/wezterm/tokyonight_night.toml".source =
      with deps;
      "${tokyonight}/extras/wezterm/tokyonight_night.toml";
  };
in
{
  options = {
    modules.wezterm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable wezterm module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
