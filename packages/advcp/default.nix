{
  stdenv,
  fetchurl,
  fetchpatch,
  upstream ? "coreutils",
}:
stdenv.mkDerivation rec {
  name = "advcp";
  version = "9.5";
  strictDeps = true;

  src = fetchurl {
    name = "source-${name}-${version}.tar.xz";
    url = "ftp://ftp.gnu.org/gnu/${upstream}/${upstream}-${version}.tar.xz";
    hash = "sha256-zTKO3qyS9qZl3p8yPJO3Eq8YWLwuDYjz9xAEaUcKG4o=";
  };

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/jarun/advcpmv/1635eb96e5dbf0dde06830db8aee0c840705d7ed/advcpmv-0.9-${version}.patch";
      hash = "sha256-LRfb4heZlAUKiXl/hC/HgoqeGMxCt8ruBYZUrbzSH+Y=";
    })
  ];

  installPhase = ''
    install -D src/cp $out/bin/advcp
    install -D src/mv $out/bin/advmv
  '';
}
