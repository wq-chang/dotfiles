{ ... }:
{
  programs.wezterm = {
    enable = true;
  };

  xdg.configFile.wezterm.source = ../configs/wezterm;
}
