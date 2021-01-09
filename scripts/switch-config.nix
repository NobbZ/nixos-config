{ writeShellScriptBin, nettools, nixUnstable }:

writeShellScriptBin "switch-config.sh" ''
  set -ex

  name=$(${nettools}/bin/hostname)
  outLink=$(mktemp -d)/result-$name

  ${nixUnstable}/bin/nix build -L \
     --out-link "$outLink" \
     .#$name

  echo "Will activate, please enter your password to elevate"
  sudo $outLink/bin/switch-to-configuration switch
  rm $outLink
''
