{
  nix,
  nixpkgs,
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
in {
  _file = ./flake.nix;

  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    programs.command-not-found.dbPath = programsdb.packages.${pkgs.system}.programs-sqlite;

    nix = {
      package = lib.mkDefault nix.packages.${pkgs.system}.nix-cli;

      settings.experimental-features = ["nix-command" "flakes"];

      registry.nixpkgs.flake = nixpkgs;

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${nixpkgs}"
    ];
  };
}
