{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    maven
    jetbrains.idea-community
  ];

  programs.zoxide = {
    enable = true;
  };
}
