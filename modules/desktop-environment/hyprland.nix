{
  config,
  isHm,
  isNixOs,
  pkgs,
  ...
}:
let
  homeConfig = {
    home.packages = with pkgs; [ hypridle ];

    systemd.user.targets = {
      hyprland-session = {
        Unit = {
          Descriptions = "Hyprland session";
          BindsTo = "graphical-session.target";
        };
      };
    };

    xdg.configFile.hypr.source =
      with config;
      lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/hypr";
  };

  nixOsConfig = {
    programs.hyprland.enable = true;
  };
in
{
  config =
    if isHm then
      homeConfig
    else if isNixOs then
      nixOsConfig
    else
      { };
}
