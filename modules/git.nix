{
  pkgs,
  lib,
  dotfilesConfig,
  ...
}:
{
  programs.git = {
    enable = true;
    userName = dotfilesConfig.gitName;
    userEmail = dotfilesConfig.email;
    iniContent = {
      core.pager = lib.mkForce "${pkgs.delta}/bin/delta -s --line-numbers";
    };
    extraConfig = {
      include.path = "~/dotfiles/configs/git/themes.gitconfig";
      merge.conflictstyle = "diff3";
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        features = "tokyonight-night";
        true-color = "always";
      };
    };
  };
}
