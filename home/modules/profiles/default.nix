_: {
  config,
  lib,
  ...
}: let
  profileEnabler = let
    reducer = l: r: {"${r}".enable = true;} // l;
  in
    builtins.foldl' reducer {} config.activeProfiles;
in {
  options.activeProfiles = lib.mkOption {type = lib.types.listOf lib.types.str;};

  config.profiles = profileEnabler;
}
