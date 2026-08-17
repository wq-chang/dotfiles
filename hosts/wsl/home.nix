{ customPkgs, pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    customPkgs.aws-local
    github-copilot-cli
    lazydocker
    unzip
    zip
  ];

  programs.zoxide = {
    enable = true;
  };
}
