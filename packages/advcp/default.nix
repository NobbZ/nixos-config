{
  stdenv,
  fetchurl,
  fetchpatch,
  ...
}: let
  upstream = "coreutils";
in
  stdenv.mkDerivation rec {
    name = "advcp";
    version = "8.30";

    src = fetchurl {
      name = "source-${name}-${version}.tar.xz";
      url = "ftp://ftp.gnu.org/gnu/${upstream}/${upstream}-${version}.tar.xz";
      sha256 = "0mxhw43d4wpqmvg0l4znk1vm10fy92biyh90lzdnqjcic2lb6cg8";
    };

    patches = [
      (fetchpatch {
        url = "https://github.com/mrdrogdrog/advcpmv/raw/496bcc9f1e8a13768066c353c238a475ccb91329/advcpmv-0.8-8.30.patch";
        sha256 = "0mw0ramg4ydqdqs33kw9m0rjvw5fvfa0scsq753pn7biwx6gx9hx";
      })
    ];

    installPhase = ''
      install -D src/cp $out/bin/advcp
      install -D src/mv $out/bin/advmv
    '';
  }
