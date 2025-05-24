{
  config,
  isHm,
  lib,
  ...
}:
let
  cfg = config.modules.lazygit;

  homeConfig = {
    programs.lazygit = {
      enable = true;
    };

    xdg.configFile.lazygit.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/lazygit";
  };
in
{
  options = {
    modules.lazygit = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable lazygit module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
