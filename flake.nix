{
  description = "Dotfiles flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      dotfilesConfig = builtins.fromJSON (builtins.readFile ./dotfiles.json);
      deps = builtins.fromJSON (builtins.readFile ./deps.json);
      withArch = arch: host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${arch};
          modules = [ ./hosts/${host}/home.nix { _module.args = { inherit dotfilesConfig deps; }; } ];
        };
    in
    {
      defaultPackage = {
        aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
        x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      };
      homeConfigurations = {
        "linux" = withArch "x86_64-linux" "linux";
      };
    };
}
