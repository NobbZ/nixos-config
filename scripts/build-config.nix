{ writeShellScriptBin, nettools, nixUnstable, ... }:

writeShellScriptBin "build-config.sh" ''
  set -ex

  if [ -z $1 ]; then
    name=$(${nettools}/bin/hostname)
  else
    name=$1
  fi

  ${nixUnstable}/bin/nix build -L \
    --out-link "result-$name" \
    .#$name
''
