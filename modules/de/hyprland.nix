{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
  };

  programs.qt.enable = true;
}
