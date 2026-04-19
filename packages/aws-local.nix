{
  deps,
  depsLock,
  pkgs,
  ...
}:
let
  sourceMeta = depsLock.awscli-local;
in
pkgs.python3Packages.buildPythonApplication {
  pname = sourceMeta.name;
  version = sourceMeta.version;
  pyproject = true;

  src = deps.awscli-local;

  build-system = with pkgs.python3Packages; [ setuptools ];

  dependencies = with pkgs.python3Packages; [ localstack-client ];

  doCheck = false;

  dontUsePythonImportsCheck = true;

  meta = with pkgs.lib; {
    description = "Thin wrapper around the 'aws' command line interface for use with LocalStack";
    homepage = "https://github.com/localstack/awscli-local";
    license = licenses.asl20;
  };
}
