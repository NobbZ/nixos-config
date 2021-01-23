{ writeShellScript, nixUnstable, nettools, ... }:

writeShellScript "switch-config.sh" ''
  set -ex

  name=""
  user="$USER"
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

      --user)
        user=$1; shift 1
        ;;
    esac
  done

  if [ -z "$name" ]; then
    if [ -z "$targetHost" ]; then
      name=$(${nettools}/bin/hostname)
    else
      printf "--name needs to be specified"
      exit
    fi
  fi

  outLink=$(mktemp -d)/result-$name

  ${nixUnstable}/bin/nix build -L \
    --out-link "$outLink" \
    ".#$name"

  if [ -z "$targetHost" ]; then
    $outLink/activate
  else
    storePath=$(readlink "$outLink")
    nix copy --to "ssh://root@$targetHost" "$storePath"
    ssh "$user@$targetHost" "$storePath/activate"
  fi

  rm $outLink
''
