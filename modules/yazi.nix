{
  config,
  deps,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.yazi;

  homeConfig = {
    programs.yazi = {
      enable = true;
      plugins = with pkgs.yaziPlugins; {
        inherit full-border git;
      };
      initLua = ''
        require("full-border"):setup({
          type = ui.Border.ROUNDED,
        })
        require("git"):setup()
      '';
      settings = {
        plugin.prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";

          }
        ];
      };
    };

    xdg.configFile."yazi/theme.toml".source =
      with deps;
      "${tokyonight}/extras/yazi/tokyonight_night.toml";
  };
in
{
  options = {
    modules.yazi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable yazi module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
