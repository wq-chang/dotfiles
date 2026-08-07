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

    modelData = deps.pi-ai-model-data;

    # pi >= 0.84.0 split telemetry into its own workspace package
    # (packages/telemetry) and made coding-agent depend on the client and
    # protocol workspaces. The nixpkgs buildPhase (still written for 0.83.0)
    # only builds ai/tui/agent, so their dist/ type declarations don't exist
    # yet when ai and coding-agent are compiled. Build them first, following
    # the upstream root build order.
    preBuild = ''
      npx tsgo -p packages/telemetry/tsconfig.build.json
      npx tsgo -p packages/protocol/tsconfig.build.json
      npx tsgo -p packages/client/tsconfig.build.json
    '';

    # The inherited postInstall replaces the pi-ai/pi-agent-core/pi-tui
    # workspace symlinks with real copies and deletes the remaining workspace
    # symlinks. pi-agent-core's dist statically re-exports from
    # @earendil-works/pi-telemetry at runtime, so the new workspace packages
    # must be copied in as real directories (surviving the symlink sweep)
    # before the inherited postInstall runs.
    postInstall =
      ''
        local nm="$out/lib/node_modules/pi-monorepo/node_modules"

        for ws in @earendil-works/pi-telemetry:packages/telemetry \
                  @earendil-works/pi-protocol:packages/protocol \
                  @earendil-works/pi-client:packages/client; do
          IFS=: read -r pkg src <<< "$ws"
          rm -f "$nm/$pkg"
          cp -r "$src" "$nm/$pkg"
        done
      ''
      + (oldAttrs.postInstall or "");
  });
}
