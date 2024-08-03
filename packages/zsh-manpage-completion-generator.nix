{ deps, pkgs }:
pkgs.buildGoModule rec {
  pname = "zsh-manpage-completion-generator";
  version = "1.0.2";

  src = deps.zsh-manpage-completion-generator;

  vendorHash = "sha256-Wb00v363VjrRKMRQ2beA1pxRYB7LY9yTHPdiXIDdLQA=";

  meta = {
    description = "Generate zsh completions from man page";
    homepage = "https://github.com/umlx5h/zsh-manpage-completion-generator";
    changelog = "https://github.com/umlx5h/zsh-manpage-completion-generator/releases/tag/v${version}";
    license = pkgs.lib.licenses.mit;
    mainProgram = "zsh-manpage-completion-generator";
  };
}
