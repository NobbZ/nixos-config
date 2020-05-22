{ fetchFromGitHub, stdenv, lib, ocaml-ng, ... }:

let
  ocamlPackages = ocaml-ng.ocamlPackages_4_10;

  inherit (ocamlPackages) buildDunePackage cppo yojson stdlib-shims menhir;

  ppxy_yojson_conv_lib = buildDunePackage rec {
    pname = "ppx_yojson_conv_lib";
    version = "0.13.0";

    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_yojson_conv_lib";
      rev = "v${version}";
      sha256 = "0bnap0s2kqsacjghlhqikcfas820is0hz8ifqfbqqk8b9y1wfcrb";
    };

    buildInputs = [ yojson ];
  };

in buildDunePackage rec {
  pname = "lsp";
  version = "2020-05-18";

  useDune2 = true;

  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "ocaml-lsp";
    rev = "5d1d5d8b32f7be4f641c60e4d817e339886eb138";
    sha256 = "0p20i2my1qxmp4y9364syxvqpdnnngzlip3c3k423lbzylsgrcmm";
    fetchSubmodules = true;
  };

  postBuild = ''
    make lsp-server
    find . -name ocamllsp
  '';

  postInstall = ''
    mkdir -p $out/bin
    install ./_build/install/default/bin/ocamllsp $out/bin/ocamllsp
  '';

  buildInputs = [ cppo yojson ppxy_yojson_conv_lib stdlib-shims menhir ];
}
