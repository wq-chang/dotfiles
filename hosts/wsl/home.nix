{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    maven
  ];

  programs.zoxide = {
    enable = true;
  };
}
