{ sources, fetchFromGitHub, stdenv, lib, ocaml-ng, ... }:

let
  ocamlPackages = ocaml-ng.ocamlPackages_4_10;

  inherit (ocamlPackages)
    buildDunePackage cppo yojson stdlib-shims menhir uutf dune-build-info;

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
    inherit (sources.ocaml-lsp) owner repo rev;
    sha256 = "sha256-RCFWYm0r9aEWJam4gP5HuDk6UPOZmFQN8QYni7GPxRA=";
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
