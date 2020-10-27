{ sources, stdenvNoCC, xsel }:
let
  source = builtins.fromJSON (builtins.readFile ./rofi-unicode.json);
in
stdenvNoCC.mkDerivation rec {
  pname = "rofiemoji-rofiunicode";
  version = "${source.rev}";

  src = builtins.fetchGit {
    inherit (source) rev url;
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
