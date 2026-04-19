{ deps, depsLock, ... }:
final: prev:
let
  sourceMeta = depsLock.github-copilot-cli;
  basePackage = prev.github-copilot-cli;
in
{
  github-copilot-cli = basePackage.overrideAttrs (oldAttrs: {
    version = sourceMeta.version;
    src = deps.github-copilot-cli;
    meta = oldAttrs.meta // {
      changelog = "https://github.com/github/copilot-cli/releases/tag/${sourceMeta.tag}";
    };
  });
}
