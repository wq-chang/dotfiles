{ deps, pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      italic-text = "always";
      theme = "tokyonight_night";
    };
    themes = with pkgs; {
      tokyonight_night = {
        file = "extras/sublime/tokyonight_night.tmTheme";
        src = with deps.tokyonight; pkgs.fetchgit {
          inherit url branchName rev hash sparseCheckout;
        };
      };
    };
  };
}
