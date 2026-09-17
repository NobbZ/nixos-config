# temporarily fixes sops-nix, see:
# https://github.com/Mic92/sops-nix/issues/983
{
  nixpkgs.overlays = [
    (final: prev: {
      buildGo125Module = prev.buildGoModule;
    })
  ];
}
