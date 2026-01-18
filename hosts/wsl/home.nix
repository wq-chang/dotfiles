{ pkgs, ... }:
let
  awslocal = pkgs.callPackage ../../packages/aws-local.nix { };
in
{
  home.packages = with pkgs; [
    awscli2
    awslocal
    lazydocker
    unzip
    zip
  ];

  programs.zoxide = {
    enable = true;
  };
}
