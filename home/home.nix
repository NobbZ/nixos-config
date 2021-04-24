{ pkgs, lib, nixpkgs, unstable, self, ... }:
let
  nixPath = builtins.concatStringsSep ":" [
    "nixpkgs=${pkgs.inputs.unstable}"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];
in
{
  nixpkgs.config.allowUnfree = true;

  imports = [ ./modules ./profiles ];

  profiles.base.enable = true;
  fonts.fontconfig.enable = true;

  systemd.user = {
    sessionVariables = { NIX_PATH = nixPath; };
  };

  xsession.windowManager.awesome.enable = true;

  home = {
    sessionVariables = { NIX_PATH = nixPath; };

    packages = let
      p = pkgs;
      s = self;
    in [
      p.cachix
      # nix-prefetch-scripts
      p.nix-review
      p.exercism
      p.tmate
      p.element-desktop
      p.powershell
      s.dracula-konsole

      p.fira-code
      p.cascadia-code

      (p.callPackage ({ lib, buildGoModule, fetchFromGitHub }:

        # Currently `buildGo114Module` is passed as `buildGoModule` from
        # `../default.nix`. Please remove the fixed 1.14 once a new release has been
        # made and the issue linked below has been closed upstream.

        # https://github.com/Arkweid/lefthook/issues/151

        buildGoModule rec {
          pname = "lefthook";
          version = "065b24f-git";

          src = fetchFromGitHub {
            name = "${pname}-${version}-source";
            rev = "065b24f";
            owner = "Arkweid";
            repo = "lefthook";
            sha256 = "sha256-GCZvrG9SK1rR8lcH7aiy5yASDz83TfPWm5n4Ub5i4/M=";
          };

          vendorSha256 = "sha256-XR7xJZfgt0Hx2DccdNlwEmuduuVU8IBR0pcIUyRhdko=";

          doCheck = false;

          meta = with lib; {
            description = "Fast and powerful Git hooks manager for any type of projects";
            homepage = "https://github.com/Arkweid/lefthook";
            license = licenses.mit;
            maintainers = with maintainers; [ rencire ];
          };
        }) {})
    ];

    stateVersion = "20.09";
  };
}
