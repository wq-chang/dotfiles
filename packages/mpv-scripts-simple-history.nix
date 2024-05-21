{ deps, pkgs, ... }:
let
  scriptsDir = "$out/share/mpv/scripts";
  scriptName = "SimpleHistory.lua";
in
pkgs.stdenv.mkDerivation {
  name = "mpv-simple-history";
  src =
    with deps.mpv-scripts;
    pkgs.fetchgit {
      inherit
        url
        branchName
        rev
        hash
        ;
    };
  unpackPhase = "true";
  installPhase = ''
    runHook preInstall

    mkdir -p ${scriptsDir}
    cp $src/scripts/${scriptName} ${scriptsDir}/${scriptName}

    runHook postInstall
  '';

  passthru = {
    inherit scriptName;
  };

  meta = with pkgs.lib; {
    description = "mpv simple history";
    homepage = "https://github.com/Eisa01/mpv-scripts";
    license = licenses.mit;
  };
}
