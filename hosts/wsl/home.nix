{ pkgs, ... }:
let

  awslocal = pkgs.callPackage ../../packages/aws-local.nix { };
in
{
  home.packages = with pkgs; [
    awscli2
    awslocal
    go
    lazydocker
    localstack
    maven
    nodejs_24
    tenv
    terraform-local
    zip
  ];

  programs.zoxide = {
    enable = true;
  };
}
