{
  deps,
  pkgs,
  config,
  ...
}:
with pkgs;
let
  tokyonight = fetchgit {
    inherit (deps.tokyonight)
      url
      branchName
      rev
      hash
      sparseCheckout
      ;
  };
in
{
  home.packages = [ wezterm ];

  xdg.configFile.wezterm.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/wezterm";
  home.file.".local/share/wezterm/tokyonight_night.toml".source = "${tokyonight}/extras/wezterm/tokyonight_night.toml";
}
