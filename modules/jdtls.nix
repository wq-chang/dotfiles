{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lombok
    jdt-language-server
    vscode-extensions.vscjava.vscode-java-debug
    vscode-extensions.vscjava.vscode-java-test
  ];
}
