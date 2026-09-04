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
      theme = fromTOML (builtins.readFile "${deps.tokyonight}/extras/yazi/tokyonight_night.toml");

      mgr = removeAttrs theme.mgr [
        "tab_active"
        "tab_inactive"
      ];

      # Newer yazi versions renamed the `name` key in `[filetype].rules` to `url`
      filetype = theme.filetype // {
        rules = map (
          rule: if rule ? name then (removeAttrs rule [ "name" ]) // { url = rule.name; } else rule
        ) theme.filetype.rules;
      };

    in
    theme
    // {
      mgr = mgr // {
        syntect_theme = "${deps.tokyonight}/extras/sublime/tokyonight_night.tmTheme";
      };

      filetype = filetype;

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
      shellWrapperName = "y";
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
        mgr.linemode = "size";
        plugin.prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
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
