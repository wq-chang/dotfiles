{
  description = "Dotfiles flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfilesConfigs.url = "git+ssh://git@github.com/wq-chang/dotfiles-configs";
  };

  outputs =
    {
      dotfilesConfigs,
      nixos-wsl,
      nixpkgs,
      home-manager,
      ...
    }:
    let
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
              ./hosts/${user}/configuration.nix
              nixos-wsl.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${dotfilesConfig.username} = import ./hosts/home-core.nix;
                  extraSpecialArgs = {
                    inherit deps dotfilesConfig;
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
      nixosConfigurations = mkNixOsConfig "wsl";
    };
}
