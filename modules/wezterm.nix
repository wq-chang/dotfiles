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

  homeConfig = with pkgs; {
    home.packages = [ wezterm ];

    xdg.configFile.wezterm.source =
      with config;
      config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/wezterm";

    home.file.".local/share/wezterm/tokyonight_night.toml".source =
      with deps;
      "${tokyonight}/extras/wezterm/tokyonight_night.toml";
  };
in
with lib;
{
  options = {
    modules.wezterm = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable wezterm module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
