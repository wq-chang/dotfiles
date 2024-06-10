{ isNixOs, pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland";

  nixOsConfig = {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd ${session}";
          user = "greeter";
        };
      };
    };
  };
in
{
  config = if isNixOs then nixOsConfig else { };
}
