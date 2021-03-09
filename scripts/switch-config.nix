{ writeShellScriptBin, nettools, nixUnstable }:

writeShellScriptBin "switch-config.sh" ''
  set -ex

  name=""
  targetHost=""

  while (( $# > 0 )); do
    i=$1; shift 1

    case "$i" in
      --targetHost)
        targetHost=$1; shift 1
        ;;

      --name)
        name=$1; shift 1
        ;;
    esac
  done

  if [ -z "$name" ]; then
    if [ -z "$targetHost" ]; then
      name=$(${nettools}/bin/hostname)
    else
      printf "--name needs to be specified"
      exit 1
    fi
  fi
  outLink=$(mktemp -d)/result-$name

  # nixos-rebuild build -L \
  #    --out-link "$outLink" \
  #    .#$name

  if [ -z "$targetHost" ]; then
    echo "Will activate, please enter your password to elevate"
    sudo nixos-rebuild switch -L --flake .#$name
  else
    storePath=$(readlink "$outLink")
    nix copy --to "ssh://root@$targetHost" "$storePath"
    ssh "root@$targetHost" "$storePath/bin/switch-to-configuration" switch
  fi
''
