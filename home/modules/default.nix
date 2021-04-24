{ filterAttrs, mapAttrs, mapAttrsToList, ... }:

let
  modules = let
    all = builtins.readDir ./.;
    dirs = filterAttrs (k: v: v == "directory") all;
  in mapAttrs (k: v: ./. + "/${k}") dirs;
in
{
  all-modules = mapAttrsToList (k: v: v) modules;
} // modules
