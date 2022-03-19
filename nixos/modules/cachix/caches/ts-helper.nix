{
  config,
  lib,
  ...
}: {
  nix = lib.mkIf (config.networking.hostName != "delly-nixos") {
    settings.substituters = [
      "https://ts-helper.cachix.org"
    ];
    settings.trusted-public-keys = [
      "ts-helper.cachix.org-1:l9XtzxPqlR/lKsKpTS+DcCn4cCuYiUSgGzIsLF3vz9Q="
    ];
  };
}
