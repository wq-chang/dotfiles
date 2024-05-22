{ deps, pkgs, ... }:
with pkgs;
{
  programs.bat = {
    enable = true;
    config = {
      italic-text = "always";
      theme = "tokyonight_night";
    };
    themes = {
      tokyonight_night = {
        file = "extras/sublime/tokyonight_night.tmTheme";
        src = fetchgit {
          inherit (deps.tokyonight)
            url
            branchName
            rev
            hash
            sparseCheckout
            ;
        };
      };
    };
  };
}
