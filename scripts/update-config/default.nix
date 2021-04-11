{ writeShellScript, lib, inputs, nixUnstable, ... }:
let
  hostNames = builtins.attrNames inputs.self.homeConfigurations;
  hostNamesBash = builtins.map (n: ".#${n}") hostNames;
  hostNamesArray = "(${lib.escapeShellArgs hostNamesBash})";
in
writeShellScript "update-config.sh" ''
  set -ex
  ${nixUnstable}/bin/nix flake update --recreate-lock-file --commit-lock-file

  hosts=${hostNamesArray}

  ${nixUnstable}/bin/nix build -L "''${hosts[@]}"
''
