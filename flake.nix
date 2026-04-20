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

      isDarwinSystem = system: lib.hasSuffix "darwin" system;

      mkHomeDirectory =
        system: username: if isDarwinSystem system then "/Users/${username}" else "/home/${username}";

      mkSpecialArgs =
        context:
        {
          isHm,
          isNixOs,
        }:
        let
          isDarwin = isDarwinSystem context.host.system;
        in
        context.commonArgs
        // {
          inherit isDarwin isHm isNixOs;
        };

      mkHostContext =
        hostName: host:
        let
          dotfilesConfig = dotfilesConfigs.${hostName} // {
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

          customPkgs = import ./packages {
            inherit deps depsLock pkgs;
          };
        in
        {
          inherit
            dotfilesConfig
            overlays
            pkgs
            ;
          commonArgs = {
            inherit
              customPkgs
              deps
              dotfilesConfig
              ;
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

      mkSystemModules = context: host: homeManagerModule: [
        {
          nixpkgs = {
            inherit (context) overlays;
            config.allowUnfree = true;
          };
        }
        host.moduleConfig
        ./modules
        host.systemModule
        homeManagerModule
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = mkSpecialArgs context {
              isHm = true;
              isNixOs = false;
            };
            users.${context.dotfilesConfig.username}.imports = mkHomeModules host;
          };
        }
      ];

      mkSystemConfiguration =
        {
          builder,
          extraModules ? [ ],
          homeManagerModule,
          host,
          hostName,
          isNixOs,
        }:
        let
          context = mkHostContext hostName host;
        in
        builder {
          system = host.system;
          specialArgs = mkSpecialArgs context {
            isHm = false;
            inherit isNixOs;
          };
          modules = mkSystemModules context host homeManagerModule ++ extraModules;
        };

      mkNixOsConfiguration =
        hostName: host:
        mkSystemConfiguration {
          builder = lib.nixosSystem;
          extraModules = lib.optionals (host.enableWsl or false) [ nixos-wsl.nixosModules.default ];
          homeManagerModule = home-manager.nixosModules.home-manager;
          inherit host hostName;
          isNixOs = true;
        };

      mkDarwinConfiguration =
        hostName: host:
        mkSystemConfiguration {
          builder = darwin.lib.darwinSystem;
          homeManagerModule = home-manager.darwinModules.home-manager;
          inherit host hostName;
          isNixOs = false;
        };

      mkHomeConfiguration =
        hostName: host:
        let
          context = mkHostContext hostName host;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = context.pkgs;
          extraSpecialArgs = mkSpecialArgs context {
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
