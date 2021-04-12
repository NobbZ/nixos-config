{ pkgs, nixpkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    registry.nixpkgs.flake = nixpkgs;
  };

  environment.systemPackages = [ pkgs.nixFlakes ];
}
