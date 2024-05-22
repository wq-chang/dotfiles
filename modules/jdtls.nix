{ pkgs, ... }:
with pkgs;
{
  home.packages = [
    lombok
    jdt-language-server
    vscode-extensions.vscjava.vscode-java-debug
    vscode-extensions.vscjava.vscode-java-test
  ];

  home.sessionVariables = {
    LOMBOK = "${lombok}/share/java/lombok.jar";
    JAVA_DEBUG =
      vscode-extensions.vscjava.vscode-java-debug
      + "/share/vscode/extensions/vscjava.vscode-java-debug/server";
    JAVA_TEST =
      vscode-extensions.vscjava.vscode-java-test
      + "/share/vscode/extensions/vscjava.vscode-java-test/server";
  };
}
