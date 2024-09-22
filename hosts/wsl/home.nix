{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    lazydocker
    maven
  ];

  programs.zoxide = {
    enable = true;
  };
}
