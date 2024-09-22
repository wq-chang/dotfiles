{
  config,
  isHm,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.neovim;

  homeConfig = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.java = {
      enable = true;
      package = pkgs.jdk21;
    };

    modules.python.packages = p: with p; [ debugpy ];

    home.packages = with pkgs; [
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
      nixd
      nodePackages.typescript-language-server
      pyright
      terraform-ls
      vscode-langservers-extracted # jsonls

      # jdtls
      lombok
      jdt-language-server
      vscode-extensions.vscjava.vscode-java-debug
      vscode-extensions.vscjava.vscode-java-test
    ];

    xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/neovim";

    home.sessionVariables = with pkgs; {
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
{
  options = {
    modules.neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable neovim module
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (if isHm then homeConfig else { });
}
