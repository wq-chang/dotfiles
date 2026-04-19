{
  deps,
  depsLock,
  lib,
}:
let
  overlayFiles = lib.sort builtins.lessThan (
    builtins.attrNames (
      lib.filterAttrs (
        name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
      ) (builtins.readDir ./.)
    )
  );

  customPackagesOverlay = final: _prev: {
    customPkgs = import ../packages {
      pkgs = final;
      inherit deps depsLock;
    };
  };

  extraOverlays = map (
    fileName:
    import (./. + "/${fileName}") {
      inherit deps depsLock lib;
    }
  ) overlayFiles;
in
[
  customPackagesOverlay
]
++ extraOverlays
