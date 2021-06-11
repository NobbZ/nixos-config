{ config, pkgs, nixpkgs, nix,  lib, ... }:

let hostname = config.networking.hostName; in

{
  nix = {
    package = nix.packages.x86_64-linux.nix; # pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ${lib.optionalString (hostname == "delly-nixos") "ca-derivations ca-references"}
    '';

    registry.nixpkgs.flake = nixpkgs;
  };

  environment.systemPackages = [ nix.packages.x86_64-linux.nix ];
}
