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
in
map (
  fileName:
  import (./. + "/${fileName}") {
    inherit deps depsLock lib;
  }
) overlayFiles
