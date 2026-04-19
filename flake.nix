{
  description = "Dotfiles flakes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      darwin,
      dotfilesConfigs,
      home-manager,
      nixos-wsl,
      nixpkgs,
      ...
    }:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts;
      depsLib = import ./lib/deps.nix { inherit lib; };
      depsLock = depsLib.readDepsLock ./deps-lock.json;

      mkHomeDirectory =
        system: username:
        if lib.hasSuffix "darwin" system then "/Users/${username}" else "/home/${username}";

      mkHostContext =
        hostName: host:
        let
          dotfilesConfig = dotfilesConfigs.${host.configKey or hostName} // {
            user = hostName;
          };

          bootstrapPkgs = import nixpkgs {
            system = host.system;
            config.allowUnfree = true;
          };

          deps = depsLib.mkDeps {
            pkgs = bootstrapPkgs;
            inherit depsLock;
          };

          overlays = import ./overlays {
            inherit deps depsLock lib;
          };

          pkgs = import nixpkgs {
            system = host.system;
            inherit overlays;
            config.allowUnfree = true;
          };
        in
        {
          inherit
            deps
            dotfilesConfig
            host
            overlays
            pkgs
            ;
          customPkgs = pkgs.customPkgs;
          commonArgs = {
            inherit
              deps
              depsLock
              dotfilesConfig
              hostName
              ;
            customPkgs = pkgs.customPkgs;
            homeDirectory = mkHomeDirectory host.system dotfilesConfig.username;
            homeStateVersion = host.homeStateVersion;
            systemStateVersion = host.systemStateVersion or null;
          };
        };

      mkHomeModules = host: [
        ./hosts/common/home.nix
        host.moduleConfig
        ./modules
        host.homeModule
      ];

      mkNixOsConfiguration =
        hostName: host:
        let
          context = mkHostContext hostName host;
        in
        lib.nixosSystem {
          system = host.system;
          specialArgs = context.commonArgs // {
            isHm = false;
            isNixOs = true;
          };
          modules = [
            {
              nixpkgs = {
                inherit (context) overlays;
                config.allowUnfree = true;
              };
            }
            host.moduleConfig
            ./modules
            host.systemModule
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = context.commonArgs // {
                  isHm = true;
                  isNixOs = false;
                };
                users.${context.dotfilesConfig.username}.imports = mkHomeModules host;
              };
            }
          ]
          ++ lib.optionals (host.enableWsl or false) [ nixos-wsl.nixosModules.default ];
        };

      mkDarwinConfiguration =
        hostName: host:
        let
          context = mkHostContext hostName host;
        in
        darwin.lib.darwinSystem {
          system = host.system;
          specialArgs = context.commonArgs // {
            isHm = false;
            isNixOs = false;
          };
          modules = [
            {
              nixpkgs = {
                inherit (context) overlays;
                config.allowUnfree = true;
              };
            }
            host.moduleConfig
            ./modules
            host.systemModule
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = context.commonArgs // {
                  isHm = true;
                  isNixOs = false;
                };
                users.${context.dotfilesConfig.username}.imports = mkHomeModules host;
              };
            }
          ];
        };

      mkHomeConfiguration =
        hostName: host:
        let
          context = mkHostContext hostName host;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = context.pkgs;
          extraSpecialArgs = context.commonArgs // {
            isHm = true;
            isNixOs = false;
          };
          modules = mkHomeModules host;
        };

      nixosHosts = lib.filterAttrs (_name: host: (host.kind or "nixos") == "nixos") hosts;
      darwinHosts = lib.filterAttrs (_name: host: (host.kind or "") == "darwin") hosts;
      homeHosts = lib.filterAttrs (_name: host: host ? homeModule) hosts;
    in
    {
      darwinConfigurations = lib.mapAttrs mkDarwinConfiguration darwinHosts;
      homeConfigurations = lib.mapAttrs mkHomeConfiguration homeHosts;
      nixosConfigurations = lib.mapAttrs mkNixOsConfiguration nixosHosts;
    };
}
