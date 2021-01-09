{ writeShellScriptBin, nettools, ... }:

writeShellScriptBin "build-config.sh" ''
  set -ex

  if [ -z $1 ]; then
    name=$(${nettools}/bin/hostname)
  else
    name=$1
  fi

  nix build -L \
    --out-link "result-$name" \
    .#$name
''
