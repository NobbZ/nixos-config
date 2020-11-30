{ sources, fetchFromGitHub, ocaml-ng, ... }:
let
  ocamlPackages = ocaml-ng.ocamlPackages_4_10;

  ocamlLspSourceSha = "1v9n4frag6igrqg774crh56vjjabmkkjwc2p6pyrzsyiq8b05w3l";

  inherit (ocamlPackages)
    buildDunePackage cppo yojson stdlib-shims menhir uutf dune-build-info;

  result = buildDunePackage rec {
    pname = "result";
    version = "1.5";

    src = fetchFromGitHub {
      name = "source-${pname}-${version}";
      owner = "janestreet";
      repo = "result";
      rev = version;
      sha256 = "166laj8qk7466sdl037c6cjs4ac571hglw4l5qpyll6df07h6a7q";
    };
  };

  csexp = buildDunePackage rec {
    pname = "csexp";
    version = "1.3.1";

    useDune2 = true;

    src = fetchFromGitHub {
      name = "source-${pname}-${version}";
      owner = "ocaml-dune";
      repo = "csexp";
      rev = "${version}";
      sha256 = "117c4kipiag2mp1bspkrrs41c1p24hk8ndr4p0rvfx2i6rb9bsp0";
    };

    buildInputs = [ result ];
  };

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

in
buildDunePackage rec {
  pname = "lsp";
  version = sources.ocaml-lsp.rev;

  useDune2 = true;

  src = fetchFromGitHub {
    name = "source-${pname}-${version}";
    inherit (sources.ocaml-lsp) owner repo rev;
    sha256 = ocamlLspSourceSha;
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
    csexp
    result
  ];
}
