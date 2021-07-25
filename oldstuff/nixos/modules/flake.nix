{ config, pkgs, nixpkgs-2105, nix, lib, ... }:
let
  hostname = __trace config.networking.hostName config.networking.hostName;
  caEnabled = __elem hostname [ "delly-nixos" "tux-nixos" ];
  caOpts = __trace (lib.optionalString caEnabled "ca-derivations ca-references") (lib.optionalString caEnabled "ca-derivations ca-references");
in
{
  nix = {
    package = nix.packages.x86_64-linux.nix; # pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ${caOpts}
    '';

    registry.nixpkgs.flake = nixpkgs-2105;
  };

  environment.systemPackages = [ nix.packages.x86_64-linux.nix ];
}
