{ pkgs ? import <nixpkgs> {  } }:

pkgs.stdenv.mkDerivation {
  name = "dns-primary-git";

  buildInputs = with pkgs; [
    ocaml
    opam
    dune_2
    ocamlPackages.utop
    pkg-config
    gcc
    gmp
    bintools-unwrapped
    gmp
  ];
}
