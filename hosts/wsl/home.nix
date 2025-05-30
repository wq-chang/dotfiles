{ pkgs, ... }:
let

  awslocal = pkgs.callPackage ../../packages/aws-local.nix { };
in
{
  home.packages = with pkgs; [
    awscli2
    awslocal
    lazydocker
    localstack
    maven
    nodejs_24
    tenv
    terraform-local
  ];

  programs.zoxide = {
    enable = true;
  };
}
