{ pkgs, nixpkgs, nix, ... }:

{
  nix = {
    package = nix.packages.x86_64-linux.nix; # pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations ca-references
    '';

    registry.nixpkgs.flake = nixpkgs;
  };

  environment.systemPackages = [ nix.packages.x86_64-linux.nix ];
}
