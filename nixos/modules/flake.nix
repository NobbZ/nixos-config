{ pkgs, nixpkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations ca-references
    '';

    registry.nixpkgs.flake = nixpkgs;
  };

  environment.systemPackages = [ pkgs.nixFlakes ];
}
