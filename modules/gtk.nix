{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.gtk;

  homeConfig =
    let
      gtk-application-prefer-dark-theme = true;
      gtk-im-module = "fcitx";
    in
    with pkgs;
    {
      gtk = {
        enable = true;
        gtk2.extraConfig = ''
          gtk-im-module="fcitx"
        '';
        gtk3.extraConfig = {
          inherit gtk-application-prefer-dark-theme gtk-im-module;
        };
        gtk4.extraConfig = {
          inherit gtk-application-prefer-dark-theme gtk-im-module;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = papirus-icon-theme;
        };
        theme = {
          name = "WhiteSur-Dark";
          package = (
            whitesur-gtk-theme.override {
              altVariants = [ "normal" ];
              colorVariants = [ "Dark" ];
              darkerColor = true;
              opacityVariants = [ "normal" ];
            }
          );
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
