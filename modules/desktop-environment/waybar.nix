{
  config,
  isHm,
  pkgs,
  ...
}:
let
  homeConfig = {
    home.packages = with pkgs; [ waybar ];

    xdg.configFile.waybar = {
      source = with config; lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/waybar";
    };
  };
in
{
  config = if isHm then homeConfig else { };
}
