{ deps, pkgs }:
pkgs.buildGoModule rec {
  pname = "zsh-manpage-completion-generator";
  version = "1.0.2";

  src =
    with deps.zsh-manpage-completion-generator;
    pkgs.fetchgit {
      inherit
        url
        branchName
        rev
        hash
        ;
    };

  vendorHash = "sha256-Wb00v363VjrRKMRQ2beA1pxRYB7LY9yTHPdiXIDdLQA=";

  meta = with pkgs.lib; {
    description = "Generate zsh completions from man page";
    homepage = "https://github.com/umlx5h/zsh-manpage-completion-generator";
    changelog = "https://github.com/umlx5h/zsh-manpage-completion-generator/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "zsh-manpage-completion-generator";
  };
}
