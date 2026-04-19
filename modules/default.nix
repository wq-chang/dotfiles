{ lib, ... }:
let
  moduleFiles = lib.sort builtins.lessThan (
    builtins.attrNames (
      lib.filterAttrs (
        name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
      ) (builtins.readDir ./.)
    )
  );
in
{
  imports = map (fileName: (./. + "/${fileName}")) moduleFiles;
}
