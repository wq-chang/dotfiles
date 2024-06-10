{ pkgs, ... }:
with pkgs;
{
  home.packages = [
    awscli2
    maven
  ];

  programs.zoxide = {
    enable = true;
  };
}
