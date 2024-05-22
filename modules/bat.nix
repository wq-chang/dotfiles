{ deps, ... }:
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
        src = deps.tokyonight;
      };
    };
  };
}
