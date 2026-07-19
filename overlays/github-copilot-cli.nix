{
  deps,
  depsLock,
  ...
}:
final: prev:
let
  sourceMeta = depsLock.github-copilot-cli;
  basePackage = prev.github-copilot-cli;
  # xdotool in nixpkgs provides libxdo.so.4, but the prebuilt webview needs .so.3
  libxdo3 = final.runCommand "libxdo3" { } ''
    mkdir -p $out/lib
    ln -s ${final.xdotool}/lib/libxdo.so.4 $out/lib/libxdo.so.3
  '';
in
{
  github-copilot-cli = basePackage.overrideAttrs (oldAttrs: {
    version = sourceMeta.version;
    src = deps.github-copilot-cli;
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
      final.webkitgtk_4_1
      libxdo3
    ];
    meta = oldAttrs.meta // {
      changelog = "https://github.com/github/copilot-cli/releases/tag/${sourceMeta.tag}";
    };
  });
}
