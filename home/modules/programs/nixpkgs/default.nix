_: {
  config,
  lib,
  ...
}: let
  allowed = config.nixpkgs.allowedUnfree;
in {
  _file = ./default.nix;

  options.nixpkgs.allowedUnfree = lib.mkOption {
    type = lib.types.listOf lib.types.string;
    default = [];
    description = ''
      Allows for  unfree packages by their name.
    '';
  };

  config.nixpkgs.config.allowUnfreePredicate =
    if (allowed == [])
    then (_: false)
    else (pkg: builtins.elem (lib.getName pkg) allowed);
}
