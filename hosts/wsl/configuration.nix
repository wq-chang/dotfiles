# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ dotfilesConfig, pkgs, ... }:
{
  imports = [
    ./module-configuration.nix
    ../../modules
  ];

  wsl = {
    enable = true;
    defaultUser = dotfilesConfig.username;
  };

  security.sudo.wheelNeedsPassword = false;

  nix = {
    settings = {
      trusted-users = [ dotfilesConfig.username ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1d";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${dotfilesConfig.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Keep this until this is fixed: https://github.com/nix-community/NixOS-WSL/issues/650
  # Prevent systemd from mounting a tmpfs over the runtime dir (and thus hiding the wayland socket)
  systemd.services."user-runtime-dir@" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = [
      "" # unset old value
      "${pkgs.coreutils}/bin/true"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
