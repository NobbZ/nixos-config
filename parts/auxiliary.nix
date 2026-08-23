_: {
  perSystem = {
    config,
    pkgs,
    inputs',
    self',
    system,
    ...
  }: {
    formatter = pkgs.alejandra;

    apps.rotate.meta.description = "rotate data keys of all sops-encrypted secrets";
    apps.rotate.program = let
      sopsrotate = pkgs.writeShellScript "sops-rotate" ''
        file=$1

        printf "Rotating %s...\n" "''${file}"
        ${pkgs.sops}/bin/sops -r -i "''${file}"
      '';
      rotate = pkgs.writeShellScript "rotate" ''
        set -euo pipefail
        cd "$(${pkgs.git}/bin/git rev-parse --show-toplevel)"

        ${pkgs.findutils}/bin/find secrets -type f \
          -exec ${sopsrotate} '{}' \;
      '';
    in "${rotate}";

    devShells.default = pkgs.mkShell {
      packages = builtins.attrValues {
        inherit (pkgs) npins sops age ssh-to-age nil alejandra lua-language-server cue statix;
      };
    };
  };
}
