{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "myenv";
  buildInputs = with pkgs; [
    hugo
    go
  ];
}
