{
  pkgs,
}:
pkgs.vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-java-test";
    publisher = "vscjava";
    version = "0.43.2";
    hash = "sha256-FUu8FOKLvwuaggquvH8IsnfHGBtXZvWRL0x2uYvV8nI=";
  };
  meta = {
    description = "Run and debug JUnit or TestNG test cases.";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-test";
    homepage = "https://github.com/microsoft/vscode-java-test";
    license = pkgs.lib.licenses.mit;
  };
}
