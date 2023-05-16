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
  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    programs.command-not-found.dbPath = programsdb.packages.${pkgs.system}.programs-sqlite;

    nix = {
      package = lib.mkDefault nix.packages.${pkgs.system}.nix;
      settings.experimental-features = ["nix-command" "flakes"];

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
