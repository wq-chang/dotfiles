{
  config,
  lib,
  isHm,
  isNixOs,
  pkgs,
  ...
}:
let
  cfg = config.modules.desktop-environment;

  homeConfig = {
    home.packages = with pkgs; [
      blueman
      gtklock
      rofi-wayland
      yazi
    ];

    services.swaync.enable = true;

    # xdg.mimeApps = {
    #   associations.added = {
    #     "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    #   };
    #   defaultApplications = {
    #     "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    #   };
    # };
  };

  nixOsConfig = {
    hardware.bluetooth.enable = true;
    programs.nm-applet.enable = true;
    security.pam.services.gtklock = { };

    # TODO: fix applet not show in ags tray
    # systemd.user.services.blueman-applet = {
    #   description = "Blueman applet";
    #   partOf = [ "graphical-session.target" ];
    #   wantedBy = [ "graphical-session.target" ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.blueman}/bin/blueman-applet";
    #   };
    # };
  };
in
with lib;
{
  options = {
    modules.desktop-environment = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable desktop environment module
        '';
      };
    };
  };

  imports = [
    ./ags.nix
    ./display-manager.nix
    ./hyprland.nix
    ./waybar.nix
  ];

  config = mkIf cfg.enable (
    if isHm then
      homeConfig
    else if isNixOs then
      nixOsConfig
    else
      { }
  );
}
