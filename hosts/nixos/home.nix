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
    fd
    gcc
    (google-chrome.override { commandLineArgs = "--enable-wayland-ime"; })
    maven
    nix-index
    nurl
    (python3.withPackages (
      p: with p; [
        argcomplete
        debugpy
      ]
    ))
    ripgrep
    transmission_4-gtk
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
    package = jdk17;
  };

  home.sessionPath = [ "$HOME/dotfiles/bin" ];
}
