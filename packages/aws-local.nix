{
  pkgs,
}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "awscli-local";
  version = "0.22.0";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-OAfPLuS73U3038i+8CfyW95SPcr4EZcg9nftleu6ZqQ=";
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
