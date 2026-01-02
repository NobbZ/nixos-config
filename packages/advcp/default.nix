{
  stdenv,
  fetchurl,
  sources,
  upstream ? "coreutils",
}:
stdenv.mkDerivation (self: {
  name = "advcp";
  version = "9.5";
  strictDeps = true;

  src = fetchurl {
    name = "source-${self.name}-${self.version}.tar.xz";
    url = "ftp://ftp.gnu.org/gnu/${upstream}/${upstream}-${self.version}.tar.xz";
    hash = "sha256-zTKO3qyS9qZl3p8yPJO3Eq8YWLwuDYjz9xAEaUcKG4o=";
  };

  patches = [
    "${sources.advcpmv}/advcpmv-0.9-${self.version}.patch"
  ];

  installPhase = ''
    install -D src/cp $out/bin/advcp
    install -D src/mv $out/bin/advmv
  '';
})
