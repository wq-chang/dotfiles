{
  pkgs,
}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "awscli_local";
  version = "0.22.2";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-B8Uyw3J1O/XxVCZFHckdbuyd6HeXSASTKamogr2sigs=";
  };

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
