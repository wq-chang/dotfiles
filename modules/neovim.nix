{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
with pkgs;
let
  cfg = config.modules.neovim;

  homeConfig = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.java = {
      enable = true;
      package = jdk17;
    };

    modules.python.packages = p: with p; [ debugpy ];

    home.packages = [
      gcc

      # formatter
      black
      google-java-format
      isort
      nixfmt-rfc-style
      prettierd
      shfmt
      stylua
      tflint

      # lsp
      lua-language-server
      nil
      pyright
      terraform-ls
      vscode-langservers-extracted # jsonls

      # jdtls
      lombok
      jdt-language-server
      vscode-extensions.vscjava.vscode-java-debug
      vscode-extensions.vscjava.vscode-java-test
    ];

    xdg.configFile.nvim.source =
      with config;
      config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/dotfiles/config/neovim";

    home.sessionVariables = {
      LOMBOK = "${lombok}/share/java/lombok.jar";
      JAVA_DEBUG =
        vscode-extensions.vscjava.vscode-java-debug
        + "/share/vscode/extensions/vscjava.vscode-java-debug/server";
      JAVA_TEST =
        vscode-extensions.vscjava.vscode-java-test
        + "/share/vscode/extensions/vscjava.vscode-java-test/server";
    };
  };
in
with lib;
{
  options = {
    modules.neovim = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable neovim module
        '';
      };
    };
  };

  config = mkIf cfg.enable (if isHm then homeConfig else { });
}
