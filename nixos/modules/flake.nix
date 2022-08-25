{
  unstable,
  nixpkgs-2105,
  nixpkgs-2111,
  nixpkgs-2205,
  nix,
  ...
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  base = "/etc/nixpkgs/channels";
  nixpkgsPath = "${base}/nixpkgs";
  nixpkgs2105Path = "${base}/nixpkgs2105";
  nixpkgs2111Path = "${base}/nixpkgs2111";
  nixpkgs2205Path = "${base}/nixpkgs2205";
in {
  options.nix.flakes.enable = lib.mkEnableOption "nix flakes";

  config = lib.mkIf config.nix.flakes.enable {
    nix = {
      package = lib.mkDefault nix.packages.x86_64-linux.nix; # pkgs.nixUnstable;
      settings.experimental-features = "nix-command flakes";

      registry.nixpkgs.flake = unstable;
      registry.nixpkgs2105.flake = nixpkgs-2105;
      registry.nixpkgs2111.flake = nixpkgs-2111;
      registry.nixpkgs2205.flake = nixpkgs-2205;

      nixPath = [
        "nixpkgs=${nixpkgsPath}"
        "nixpkgs2105=${nixpkgs2105Path}"
        "nixpkgs2111=${nixpkgs2111Path}"
        "nixpkgs2205=${nixpkgs2105Path}"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${unstable}"
      "L+ ${nixpkgs2105Path} - - - - ${nixpkgs-2105}"
      "L+ ${nixpkgs2111Path} - - - - ${nixpkgs-2111}"
      "L+ ${nixpkgs2205Path} - - - - ${nixpkgs-2205}"
    ];
  };
}
