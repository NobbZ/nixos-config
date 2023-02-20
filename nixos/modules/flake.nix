{
  unstable,
  nixpkgs-2111,
  nixpkgs-2205,
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
  nixpkgs2111Path = "${base}/nixpkgs2111";
  nixpkgs2205Path = "${base}/nixpkgs2205";
  nixpkgs2211Path = "${base}/nixpkgs2211";
in {
  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    programs.command-not-found.dbPath = programsdb.packages.${pkgs.system}.programs-sqlite;

    nix = {
      package = lib.mkDefault nix.packages.${pkgs.system}.nix; # pkgs.nixUnstable;
      settings.experimental-features = ["nix-command" "flakes"];

      registry.nixpkgs.flake = unstable;
      registry.nixpkgs2111.flake = nixpkgs-2111;
      registry.nixpkgs2205.flake = nixpkgs-2205;
      registry.nixpkgs2211.flake = nixpkgs-2211;

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
        "nixpkgs2111=${nixpkgs2111Path}"
        "nixpkgs2205=${nixpkgs2205Path}"
        "nixpkgs2105=${nixpkgs2211Path}"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${unstable}"
      "L+ ${nixpkgs2111Path} - - - - ${nixpkgs-2111}"
      "L+ ${nixpkgs2205Path} - - - - ${nixpkgs-2205}"
      "L+ ${nixpkgs2211Path} - - - - ${nixpkgs-2211}"
    ];
  };
}
