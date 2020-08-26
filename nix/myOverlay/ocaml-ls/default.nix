{ sources, fetchFromGitHub, stdenv, lib, ocaml-ng, ... }:

let
  ocamlPackages = ocaml-ng.ocamlPackages_4_10;

  inherit (ocamlPackages)
    buildDunePackage cppo yojson stdlib-shims menhir uutf dune-build-info;

  ppxy_yojson_conv_lib = buildDunePackage rec {
    pname = "ppx_yojson_conv_lib";
    version = "0.13.0";

    src = fetchFromGitHub {
      name = "source-${pname}-${version}";
      owner = "janestreet";
      repo = "ppx_yojson_conv_lib";
      rev = "v${version}";
      sha256 = "0bnap0s2kqsacjghlhqikcfas820is0hz8ifqfbqqk8b9y1wfcrb";
    };

    buildInputs = [ yojson ];
  };

in buildDunePackage rec {
  pname = "lsp";
  version = sources.ocaml-lsp.rev;

  useDune2 = true;

  src = fetchFromGitHub {
    name = "source-${pname}-${version}";
    inherit (sources.ocaml-lsp) owner repo rev;
    sha256 = "0zznswl82h2bj1q2ik9n4b6m4ql3gz2j9h6crc8bgsb9alqh5q85";
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

  buildInputs = [
    cppo
    yojson
    ppxy_yojson_conv_lib
    stdlib-shims
    menhir
    uutf
    dune-build-info
  ];
}
