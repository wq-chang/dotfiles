{ deps, pkgs, ... }:
let
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
      };
    };
  };
}
