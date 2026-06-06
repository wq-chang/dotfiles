{
  deps,
  depsLock,
  ...
}:
final: prev:
let
  sourceMeta = depsLock.pi-coding-agent;
  basePackage = prev.pi-coding-agent;
in
{
  pi-coding-agent = basePackage.overrideAttrs (oldAttrs: rec {
    version = sourceMeta.version;
    src = deps.pi-coding-agent;
    npmDeps = final.fetchNpmDeps {
      inherit src;
      hash = sourceMeta.npmDepsHash;
    };
  });
}
