{ pkgs, ... }:
with pkgs;
{
  imports = [ ../../modules/de ];

  home.packages = [
    awscli2
    maven
  ];

  programs.zoxide = {
    enable = true;
  };
}
