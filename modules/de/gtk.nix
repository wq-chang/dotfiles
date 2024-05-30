{ config, pkgs, ... }:
with pkgs;
{
  gtk = {
    enable = true;
    gtk2.extraConfig = ''
      gtk-im-module="fcitx"
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-im-module = "fcitx";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-im-module = "fcitx";
    };
    theme = {
      name = "WhiteSur-Dark";
      package = whitesur-gtk-theme;
    };
  };

  xdg.configFile = {
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
    "gtk-4.0/gtk.gresource".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.gresource";
  };
}
