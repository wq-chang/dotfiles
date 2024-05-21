{
  deps,
  dotfilesConfig,
  pkgs,
  ...
}:
let
  zsh-manpage-completion-generator =
    pkgs.callPackage ../../packages/zsh-manpage-completion-generator.nix
      { inherit deps; };
  fdm = pkgs.callPackage ../../packages/free-download-manager.nix { };
in
{
  home.username = dotfilesConfig.username;
  home.homeDirectory = "/home/${dotfilesConfig.username}";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  imports = [
    ../../modules/bat.nix
    ../../modules/direnv.nix
    ../../modules/eza.nix
    ../../modules/fonts.nix
    ../../modules/fzf.nix
    ../../modules/git.nix
    ../../modules/jdtls.nix
    ../../modules/kitty.nix
    ../../modules/lazygit.nix
    ../../modules/mpv.nix
    ../../modules/neovim.nix
    ../../modules/wezterm.nix
    ../../modules/zoxide.nix
    ../../modules/zsh.nix
  ];

  home.packages = with pkgs; [
    awscli2
    fd
    fdm
    gcc
    google-chrome
    maven
    nix-index
    nurl
    (python3.withPackages (p: with p; [ debugpy ]))
    ripgrep
    wl-clipboard
    # TODO: remove after moved to hyprland
    xsel
    zsh-manpage-completion-generator

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
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  home.sessionVariables = {
    LOMBOK = "${pkgs.lombok}/share/java/lombok.jar";
    JAVA_DEBUG =
      pkgs.vscode-extensions.vscjava.vscode-java-debug
      + "/share/vscode/extensions/vscjava.vscode-java-debug/server";
    JAVA_TEST =
      pkgs.vscode-extensions.vscjava.vscode-java-test
      + "/share/vscode/extensions/vscjava.vscode-java-test/server";
    PYTHON = "$(which python)";
  };
}
