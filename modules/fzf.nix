{
  config,
  isHm,
  lib,
  ...
}:
let
  cfg = config.modules.fzf;

  homeConfig = {
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f --strip-cwd-prefix --hidden";
      defaultOptions = [
        "--layout reverse"
        ("--bind " + "ctrl-k:kill-line," + "tab:toggle+down," + "shift-tab:toggle+up," + "alt-a:toggle-all")
      ];
      colors = {
        fg = "#c0caf5";
        bg = "-1";
        hl = "#ff9e64";
        "fg+" = "#c0caf5";
        "bg+" = "#292e42";
        "hl+" = "#ff9e64";
        info = "#7aa2f7";
        prompt = "#7dcfff";
        pointer = "#7dcfff";
        marker = "#9ece6a";
        spinner = "#9ece6a";
        header = "#9ece6a";
        scrollbar = "#3b4261";
        border = "#27a1b9";
        gutter = "-1";
      };
    };
  };
in
with lib;
{
  options = {
    modules.fzf = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable fzf module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
