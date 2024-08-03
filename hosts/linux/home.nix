{ pkgs, ... }:
{
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

  home.packages = with pkgs; [
    awscli2

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
