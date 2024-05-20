{ deps, pkgs, ... }:
let
  icon = {
    clock = "  ";
    checked = "  ";
  };
  simpleHistory = pkgs.callPackage ../packages/mpv-scripts-simple-history.nix { inherit deps; };
in
{

  programs.mpv = {
    enable = true;
    config = {
      osc = "no";
      gpu-api = "vulkan";
    };
    scripts = with pkgs.mpvScripts; [
      autoload
      modernx
      simpleHistory
      thumbfast
    ];
    scriptOpts = {
      SimpleHistory = {
        auto_run_list_idle = "distinct";
        resume_option = "force";
        resume_option_threshold = 0;

        time_seperator = icon.clock;
        header_list_duration_pre_text = icon.clock;
        header_list_length_pre_text = icon.clock;
        header_list_remaining_pre_text = icon.clock;
        text_highlight_pre_text = icon.checked;
        header_highlight_pre_text = icon.checked;
      };
    };
  };
}
