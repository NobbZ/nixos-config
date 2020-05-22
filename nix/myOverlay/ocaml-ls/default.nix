{ fetchFromGitHub, stdenv, lib, ocaml-ng, ... }:

let ocamlPackages = ocaml-ng.ocamlPackages_4_11;

in stdenv.mkDerivation rec {
  name = "ocaml-lsp";

  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "ocaml-lsp";
    rev = "5d1d5d8b32f7be4f641c60e4d817e339886eb138";
    sha256 = "0p20i2my1qxmp4y9364syxvqpdnnngzlip3c3k423lbzylsgrcmm";
    fetchSubmodules = true;
  };

  buildInputs = with ocamlPackages; [ dune_2 ocaml menhir cmdliner];
}
