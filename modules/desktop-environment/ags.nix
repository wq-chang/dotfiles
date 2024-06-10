{
  ags,
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  homeConfig = {
    programs.ags = {
      enable = true;
    };
    home.packages = with pkgs; [
      bun
      nodePackages.npm
      sassc
    ];

    xdg.configFile.ags.source =
      with config;
      config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/ags";

    home.file."dotfiles/config/ags/types".source = "${config.programs.ags.finalPackage}/share/com.github.Aylur.ags/types";
  };
in
{
  imports = lib.optional isHm ags.homeManagerModules.default;

  config = if isHm then homeConfig else { };
}
