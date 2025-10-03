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
  generateTheme =
    let
      theme = builtins.fromTOML (
        builtins.readFile "${deps.tokyonight}/extras/yazi/tokyonight_night.toml"
      );

      mgr = builtins.removeAttrs theme.manager [
        "tab_active"
        "tab_inactive"
      ];

      theme' = builtins.removeAttrs theme [ "manager" ];
    in
    theme'
    // {
      mgr = mgr // {
        syntect_theme = "${deps.tokyonight}/extras/sublime/tokyonight_night.tmTheme";
      };

      tabs = {
        active = {
          bg = "#7aa2f7";
          fg = "#15161e";
          bold = true;
        };
        inactive = {
          bg = "#292e42";
          fg = "#7aa2f7";
        };
      };
    };

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
      theme = generateTheme;
    };
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
