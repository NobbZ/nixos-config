{ config, lib, ... }:

{
  nix = {
    binaryCaches = if (config.networking.hostName == "delly-nixos") then
      lib.mkForce [
        # "https://cache.ngi0.nixos.org/"
      ]
                   else [];
    binaryCachePublicKeys = [
      "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
    ];
  };
}
