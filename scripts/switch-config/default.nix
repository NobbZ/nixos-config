{ writeShellScript, nettools, ... }:

writeShellScript "switch-config.sh" ''
  set -ex

  name=$(${nettools}/bin/hostname)
  outLink=$(mktemp -d)/result-$name

  nix build -L --out-link "$outLink" ".#$name"
  $outLink/activate
  rm $outLink
''
