{
  deps,
  depsLock,
  ...
}:
final: prev:
let
  sourceMeta = depsLock.github-copilot-cli;
  basePackage = prev.github-copilot-cli;
in
{
  github-copilot-cli = basePackage.overrideAttrs (oldAttrs: {
    version = sourceMeta.version;
    src = deps.github-copilot-cli;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"/lib/github-copilot-cli
      cp -r . "$out"/lib/github-copilot-cli
      rm -rf \
        "$out"/lib/github-copilot-cli/prebuilds/linuxmusl-* \
        "$out"/lib/github-copilot-cli/ripgrep/bin/linuxmusl-*
      runHook postInstall
    '';
    meta = oldAttrs.meta // {
      changelog = "https://github.com/github/copilot-cli/releases/tag/${sourceMeta.tag}";
    };
  });
}
