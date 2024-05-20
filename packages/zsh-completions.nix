{ deps, pkgs, ... }:
let
  toSource =
    dep:
    with dep;
    pkgs.fetchgit {
      inherit
        url
        branchName
        rev
        hash
        ;
      sparseCheckout = dep.sparseCheckout or [ ];
    };
in
pkgs.stdenv.mkDerivation {
  name = "zsh-completions";
  srcs = map toSource [
    deps.docker-cli
    deps.ohmyzsh
    deps.zsh-completions
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out
    read -r -a src_array <<< "$srcs"
    docker="''${src_array[0]}"
    ohmyzsh="''${src_array[1]}"
    zshcompletions="''${src_array[2]}"

    cp $docker/contrib/completion/zsh/_docker $out
    cp $ohmyzsh/plugins/terraform/_terraform $out
    cp $ohmyzsh/plugins/docker-compose/_docker-compose $out
    cp -r $zshcompletions/src/* $out
  '';
}
