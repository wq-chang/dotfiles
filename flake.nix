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

  outputs =
    {
      dotfilesConfigs,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      deps = builtins.fromJSON (builtins.readFile ./deps-lock.json);

      toHomeManagerPackages = sys: {
        name = sys;
        value = {
          default = home-manager.defaultPackage.${sys};
        };
      };
      mkHomeManagerConfig =
        system: user:
        let
          dotfilesConfig = dotfilesConfigs.${user};
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./hosts/${user}/home.nix
            {
              _module.args = {
                inherit deps dotfilesConfig;
                isNixOs = false;
              };
            }
          ];
        };

      mkNixOsConfig =
        user:
        let
          dotfilesConfig = dotfilesConfigs.${user};
        in
        {
          "${user}" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./hosts/${user}/configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${dotfilesConfig.username} = import ./hosts/${user}/home.nix;
                  extraSpecialArgs = {
                    inherit deps dotfilesConfig;
                    isNixOs = true;
                  };
                };
              }
              {
                _module.args = {
                  inherit deps dotfilesConfig;
                  isNixOs = true;
                };
              }
            ];
          };
        };
    in
    {
      packages = builtins.listToAttrs (map toHomeManagerPackages systems);

      homeConfigurations = {
        "linux" = mkHomeManagerConfig "x86_64-linux" "linux";
      };

      nixosConfigurations = mkNixOsConfig "nixos";
    };
}
