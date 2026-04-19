{
  deps,
  depsLock ? { },
  pkgs,
}:
let
  lib = pkgs.lib;

  packageFiles = lib.filterAttrs (
    name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
  ) (builtins.readDir ./.);

  packages = lib.mapAttrs' (
    fileName: _type:
    let
      packageName = lib.removeSuffix ".nix" fileName;
    in
    lib.nameValuePair packageName (
      pkgs.callPackage (./. + "/${fileName}") {
        inherit deps depsLock;
      }
    )
  ) packageFiles;

in
packages
