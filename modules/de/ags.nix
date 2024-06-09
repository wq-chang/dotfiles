{
  ags,
  config,
  pkgs,
  ...
}:
with pkgs;
{

  imports = [ ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;

    # extraPackages = with pkgs; [
    #   gtksourceview
    #   webkitgtk
    #   accountsservice
    # ];
  };
  home.packages = [
    bun
    nodePackages.npm
    sassc
  ];

  xdg.configFile.ags.source =
    with config;
    lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/ags";

  home.file."dotfiles/config/ags/types".source = "${config.programs.ags.finalPackage}/share/com.github.Aylur.ags/types";
}
