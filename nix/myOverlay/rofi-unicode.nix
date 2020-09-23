{ sources, stdenvNoCC, xsel }:

stdenvNoCC.mkDerivation rec {
  pname = "rofiemoji-rofiunicode";
  version = sources.rofiemoji-rofiunicode.rev;

  src = builtins.fetchGit {
    url = sources.rofiemoji-rofiunicode.repo;
    rev = sources.rofiemoji-rofiunicode.rev;
  };

  installPhase = ''
    mkdir -pv $out/{bin,lists}

    install -v lists/* $out/lists
    install -v *.sh $out/bin
  '';

  postFixup = ''
    for f in $out/bin/*.sh; do
      substituteInPlace $f \
        --replace 'DIR="$HOME/.config/rofiemoji-rofiunicode/lists"' \
                  'DIR="${placeholder "out"}/lists"' \
        --replace 'xsel' '${xsel}/bin/xsel'
    done;
  '';
}
