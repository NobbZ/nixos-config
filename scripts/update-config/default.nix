pkgs.writeShellScript "update-config.sh" ''
  set -ex
  ${pkgs.nixUnstable}/bin/nix flake update --recreate-lock-file --commit-lock-file

  hosts="${pkgs.lib.strings.concatStringsSep "\n" (builtins.map (n: ".#${n}") (builtins.attrNames self.homeConfigurations))}"

  ${pkgs.nixUnstable}/bin/nix build $hosts
''
