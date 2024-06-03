{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gtk;

  homeConfig = with pkgs; {
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
  };
in
with lib;
{
  options = {
    modules.gtk = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable gtk module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
