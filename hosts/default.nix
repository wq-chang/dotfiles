{
  wsl = {
    kind = "nixos";
    configKey = "wsl";
    system = "x86_64-linux";
    systemStateVersion = "24.05";
    homeStateVersion = "24.05";
    enableWsl = true;
    systemModule = ./wsl/configuration.nix;
    homeModule = ./wsl/home.nix;
    moduleConfig = ./wsl/module-configuration.nix;
  };
}
