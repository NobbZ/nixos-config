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

    for f in *.sh; do
      substitute $f $out/bin/$f \
        --replace 'DIR="$HOME/.config/rofiemoji-rofiunicode/lists"' \
                  'DIR="${placeholder "out"}/lists"' \
        --replace 'xsel' '${xsel}/bin/xsel'
      chmod +x $out/bin/$f
    done;
  '';
}
