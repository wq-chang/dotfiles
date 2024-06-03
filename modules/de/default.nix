{ pkgs, ... }:
with pkgs;
{
  imports = [
    ./ags.nix
    ./hyprland.nix
    ./waybar.nix
  ];

  home.packages = [
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
}
