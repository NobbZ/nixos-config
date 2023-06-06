_: {
  config,
  lib,
  pkgs,
  ...
}: {
  _file = ./hostnames.nix;

  networking.search = ["internal.nobbz.dev"];
  networking.domain = "internal.nobbz.dev";
}
