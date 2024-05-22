{
  deps,
  dotfilesConfig,
  pkgs,
  ...
}:
with pkgs;
let
  zsh-manpage-completion-generator = callPackage ../../packages/zsh-manpage-completion-generator.nix {
    inherit deps;
  };
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
    ../../modules/fzf.nix
    ../../modules/git.nix
    ../../modules/lazygit.nix
    ../../modules/neovim.nix
    ../../modules/zoxide.nix
    ../../modules/zsh.nix
  ];

  home.packages = [
    awscli2
    fd
    nurl
    ripgrep
    zsh-manpage-completion-generator

    # formatter
    black
    google-java-format
    isort
    nixpkgs-fmt
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

    # fedora only
    wl-clipboard
  ];
}
