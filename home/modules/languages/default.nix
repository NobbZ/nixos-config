_: {
  config,
  lib,
  ...
}: let
  langsEnabler = let
    reducer = l: r: {"${r}".enable = true;} // l;
  in
    builtins.foldl' reducer {} config.enabledLanguages;
in {
  _file = ./default.nix;

  options.enabledLanguages = lib.mkOption {
    default = [];
    type = lib.types.listOf lib.types.str;
  };

  config = {languages = langsEnabler;};
}
