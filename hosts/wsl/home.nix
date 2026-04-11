{ pkgs, ... }:
let
  awslocal = pkgs.callPackage ../../packages/aws-local.nix { };
in
{
  home.packages = with pkgs; [
    awscli2
    awslocal
    github-copilot-cli
    gemini-cli
    lazydocker
    unzip
    zip
  ];

  programs.zoxide = {
    enable = true;
  };
}
