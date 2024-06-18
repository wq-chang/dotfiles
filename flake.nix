{
  description = "Dotfiles flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfilesConfigs.url = "git+ssh://git@github.com/wq-chang/dotfiles-configs";
  };

  outputs =
    {
      ags,
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

      mkDeps =
        system:
        builtins.mapAttrs (
          name: value:
          nixpkgs.legacyPackages.${system}.fetchgit {
            inherit (value)
              url
              branchName
              rev
              hash
              ;
            sparseCheckout = value.sparseCheckout or [ ];
          }
        ) (builtins.fromJSON (builtins.readFile ./deps-lock.json));

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
            ./hosts/home-core.nix
            {
              _module.args = {
                dotfilesConfig = dotfilesConfig // {
                  inherit user;
                  isHm = true;
                  isNixOs = false;
                };
                deps = mkDeps system;
              };
            }
          ];
        };

      mkNixOsConfig =
        user:
        let
          system = "x86_64-linux";
          dotfilesConfig = dotfilesConfigs.${user} // {
            inherit user;
          };
          deps = mkDeps system;
        in
        {
          "${user}" = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ./hosts/configuration-core.nix
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${dotfilesConfig.username} = import ./hosts/home-core.nix;
                  extraSpecialArgs = {
                    inherit ags deps dotfilesConfig;
                    isHm = true;
                    isNixOs = false;
                  };
                };
              }
            ];
            specialArgs = {
              inherit deps dotfilesConfig;
              isHm = false;
              isNixOs = true;
            };
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
