{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim";
      git = {
        disableForcePushing = true;
        paging = {
          colorArg = "always";
          pager = "delta --line-numbers --paging=never";
        };
      };
      gui.theme = {
        activeBorderColor = [
          "#7aa2f7"
          "bold"
        ];
        inactiveBorderColor = [ "#545c7e" ];
        optionsTextColor = [ "#7aa2f7" ];
        selectedLineBgColor = [ "#292e42" ];
        selectedRangeBgColor = [ "#283457" ];
        cherryPickedCommitBgColor = [ "#283457" ];
        cherryPickedCommitFgColor = [ "#c0caf5" ];
        unstagedChangesColor = [ "#f7768e" ];
        defaultFgColor = [ "#c0caf5" ];
        searchingActiveBorderColor = [ "#27a1b9" ];
      };
    };
  };
}