{
  stdenv,
  fetchurl,
  fetchpatch,
  upstream ? "coreutils",
}:
stdenv.mkDerivation rec {
  name = "advcp";
  version = "9.1";

  src = fetchurl {
    name = "source-${name}-${version}.tar.xz";
    url = "ftp://ftp.gnu.org/gnu/${upstream}/${upstream}-${version}.tar.xz";
    hash = "sha256-YaH0ENeLp+fzelpPUObRMgrKMzdUhKMlXt3xejhYBCM=";
  };

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/jarun/advcpmv/ea268d870b475edd5960dcd55d5378abc9705958/advcpmv-0.9-${version}.patch";
      hash = "sha256-d+SRT/R4xmfHLAdOr7m4R3WFiW64P5ZH6iqDvErYCyg=";
    })
  ];

  installPhase = ''
    install -D src/cp $out/bin/advcp
    install -D src/mv $out/bin/advmv
  '';
}
