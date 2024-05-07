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
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      toHomeManagerPackages = sys: { name = sys; value = { default = home-manager.defaultPackage.${sys}; }; };
      deps = builtins.fromJSON (builtins.readFile ./deps-lock.json);
      withArch = system: user:
        let
          dotfilesConfig = dotfilesConfigs."${user}";
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./hosts/${user}/home.nix
            { _module.args = { inherit deps dotfilesConfig; }; }
          ];
        };
    in
    {
      packages = builtins.listToAttrs (map toHomeManagerPackages systems);
      homeConfigurations =
        {
          "linux" = withArch "x86_64-linux" "linux";
        };
    };
}
