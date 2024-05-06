{
  description = "Dotfiles flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfilesConfigs.url = "git+ssh://git@github.com/wq-chang/dotfiles-configs";
  };

  outputs = { dotfilesConfigs, nixpkgs, home-manager, ... }:
    let
      deps = builtins.fromJSON (builtins.readFile ./deps-lock.json);
      withArch = arch: user: host:
        let
          dotfilesConfig = dotfilesConfigs."${user}@${host}";
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${arch};
          modules = [ ./hosts/${host}/home.nix { _module.args = { inherit deps dotfilesConfig; }; } ];
        };
    in
    {
      defaultPackage = {
        aarch64-darwin = home-manager.defaultPackage.aarch64-darwin;
        x86_64-linux = home-manager.defaultPackage.x86_64-linux;
      };
      homeConfigurations = {
        "dev@linux" = withArch "x86_64-linux" "dev" "linux";
      };
    };
}
