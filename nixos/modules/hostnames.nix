_: { config, lib, pkgs, ... }:

{
  networking.search = [ "internal.nobbz.dev" ];
  networking.domain = "internal.nobbz.dev";
}
