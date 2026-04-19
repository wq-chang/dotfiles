{ lib }:
let
  githubReleaseArchiveUrl =
    url: tag:
    let
      baseUrl = lib.removeSuffix "/" (lib.removeSuffix ".git" url);
    in
    "${baseUrl}/archive/refs/tags/${tag}.tar.gz";

  selectGithubReleaseAsset =
    system: spec:
    spec.assets.${system}
      or (throw "GitHub release dependency ${spec.url} has no asset for system ${system}");

  fetchDependency =
    pkgs: spec:
    let
      depType = spec.type or "git";
      system = pkgs.stdenv.hostPlatform.system;
    in
    if depType == "git" then
      pkgs.fetchgit (
        {
          inherit (spec)
            url
            rev
            hash
            ;
        }
        // lib.optionalAttrs (spec ? branchName) {
          branchName = spec.branchName;
        }
        // lib.optionalAttrs (spec ? sparseCheckout) {
          sparseCheckout = spec.sparseCheckout;
        }
      )
    else if depType == "github-release" && spec ? assets then
      let
        asset = selectGithubReleaseAsset system spec;
      in
      pkgs.fetchurl {
        inherit (asset)
          url
          hash
          ;
      }
    else if depType == "github-release" then
      pkgs.fetchzip {
        url = githubReleaseArchiveUrl spec.url spec.tag;
        inherit (spec) hash;
      }
    else if depType == "pypi" || depType == "npm" then
      pkgs.fetchurl {
        inherit (spec)
          url
          hash
          ;
      }
    else
      throw "Unsupported dependency type: ${depType}";
in
{
  inherit githubReleaseArchiveUrl;
  inherit selectGithubReleaseAsset;

  readDepsLock = path: builtins.fromJSON (builtins.readFile path);

  mkDeps =
    {
      pkgs,
      depsLock,
    }:
    lib.mapAttrs (_name: spec: fetchDependency pkgs spec) depsLock;
}
