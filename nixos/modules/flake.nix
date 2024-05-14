{
  unstable,
  nixpkgs-2211,
  nix,
  programsdb,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  base = "/etc/nixpkgs/channels";
  nixpkgsPath = "${base}/nixpkgs";
  nixpkgs2211Path = "${base}/nixpkgs2211";
in {
  _file = ./flake.nix;

  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    programs.command-not-found.dbPath = programsdb.packages.${pkgs.system}.programs-sqlite;

    nix = {
      package = lib.mkDefault (nix.packages.${pkgs.system}.nix.overrideAttrs (oa: {
        patches =
          (oa.patches or [])
          ++ [
            (pkgs.fetchpatch {
              url = "https://github.com/eclairevoyant/nix-fork/commit/b6ae3be9c6ec4e9de55479188e76fc330b2304dd.patch";
              hash = "sha256-VyIywGo1ie059wXmGWx+bNeHz9lNk6nlkJ/Qgd1kmzw=";
            })
          ];
      }));

      settings.experimental-features = ["nix-command" "flakes"];
      settings.reject-flake-config = true;

      registry.nixpkgs.flake = unstable;
      registry.nixpkgs2211.flake = nixpkgs-2211;

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
        "nixpkgs2211=${nixpkgs2211Path}"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${unstable}"
      "L+ ${nixpkgs2211Path} - - - - ${nixpkgs-2211}"
    ];
  };
}
