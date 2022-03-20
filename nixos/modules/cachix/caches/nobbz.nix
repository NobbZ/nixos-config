{
  config,
  lib,
  ...
}: {
  nix = lib.mkIf (config.networking.hostName != "delly-nixos") {
    settings.substituters = [
      "https://nobbz.cachix.org"
    ];
    settings.trusted-public-keys = [
      "nobbz.cachix.org-1:fODxpqE4ni+pFDSuj2ybYZbMUjmxNTjA7rtUNHW61Ok="
    ];
  };
}
