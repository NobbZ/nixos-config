{ config, lib, ... }:

{
  nix = lib.mkIf (config.networking.hostName != "delly-nixos") {
    binaryCaches = [
      "https://nobbz.cachix.org"
    ];
    binaryCachePublicKeys = [
      "nobbz.cachix.org-1:fODxpqE4ni+pFDSuj2ybYZbMUjmxNTjA7rtUNHW61Ok="
    ];
  };
}
