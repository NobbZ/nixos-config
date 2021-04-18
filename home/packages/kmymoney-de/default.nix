{ runCommand, makeWrapper, kmymoney }:

runCommand "kmymoney-de-${kmymoney.version}" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/{bin,share/applications}
  makeWrapper ${kmymoney}/bin/kmymoney $out/bin/kmymoney \
    --set LANG de_DE.UTF-8
  ln -s ${kmymoney}/share/applications/org.kde.kmymoney.desktop $out/share/applications/org.kde.kmymoney.desktop
''
