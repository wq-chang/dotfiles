{ deps, pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "zsh-completions";
  srcs = with deps; [
    argcomplete
    docker-cli
    ohmyzsh
    zsh-completions
  ];
  unpackPhase = "true";
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    var_array=("argcomplete" "docker" "ohmyzsh" "zshcompletions")
    read -r -a src_array <<< "$srcs"
    for i in "''${!src_array[@]}"; do
        eval "''${var_array[$i]}=\"\''${src_array[$i]}\""
    done

    cp $argcomplete/argcomplete/bash_completion.d/_python-argcomplete $out
    cp $docker/contrib/completion/zsh/_docker $out
    cp $ohmyzsh/plugins/terraform/_terraform $out
    cp $ohmyzsh/plugins/docker-compose/_docker-compose $out
    cp -r $zshcompletions/src/* $out

    runHook postInstall
  '';
}
