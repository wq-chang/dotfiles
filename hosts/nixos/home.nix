{ pkgs, ... }:
with pkgs;
{

  imports = [
    ../../modules/bat.nix
    ../../modules/de
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

  home.packages = [
    awscli2
    gcc
    maven
    transmission_4-gtk

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
    package = jdk17;
  };
}
