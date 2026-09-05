{ customPkgs, pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    customPkgs.aws-local
    lazydocker
    unzip
    zip
  ];

  programs.zoxide = {
    enable = true;
  };
}
