{ pkgs, ... }:
with pkgs;
{
  imports = [
    ./ags.nix
    ./gtk.nix
    ./hyprland.nix
    ./waybar.nix
  ];

  home.packages = [
    blueman
    gnome.nautilus
    gtklock
    rofi-wayland
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
