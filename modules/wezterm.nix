{
  deps,
  pkgs,
  config,
  ...
}:
with pkgs;
{
  home.packages = [ wezterm ];

  xdg.configFile.wezterm.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/wezterm";
  home.file.".local/share/wezterm/tokyonight_night.toml".source = "${deps.tokyonight}/extras/wezterm/tokyonight_night.toml";
}
