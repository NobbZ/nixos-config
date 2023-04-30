{self, ...}: {
  perSystem = {
    config,
    pkgs,
    inputs',
    self',
    system,
    ...
  }: {
    formatter = self.packages.${system}.alejandra;

    apps.rotate.program = let
      sopsrotate = pkgs.writeShellScript "sops-rotate" ''
        file=$1

        printf "Rotating %s...\n" "''${file}"
        ${pkgs.sops}/bin/sops -r -i "''${file}"
      '';
      rotate = pkgs.writeShellScript "rotate" ''
        ${pkgs.git}/bin/git -c rotate-$(${pkgs.coreutils}/bin/date -Idate) >/dev/null || true

        ${pkgs.findutils}/bin/find secrets \( -name '*.yaml' -o -name '*.yml' \) -a -type f -exec ${sopsrotate} '{}' \;

        ${pkgs.git}/bin/git add secrets
        ${pkgs.git}/bin/git commit -m "chore: rotate secrets $(${pkgs.coreutils}/bin/date -Idate)"
      '';
    in "${rotate}";

    devShells.default = pkgs.mkShell {
      packages = builtins.attrValues {
        inherit (self'.packages) nil alejandra;
        inherit (inputs'.unstable.legacyPackages) npins sops age ssh-to-age;
      };
    };
  };
}
