{
  runCommand,
  makeWrapper,
  gnucash,
}:
runCommand "gnucash-de-${gnucash.version}"
{
  nativeBuildInputs = [makeWrapper];
} ''
  mkdir -p $out/{bin,share/applications}
  makeWrapper ${gnucash}/bin/gnucash $out/bin/gnucash \
    --set LANG de_DE.UTF-8
  ln -s ${gnucash}/share/applications/gnucash.desktop $out/share/applications/gnucash.desktop
''
