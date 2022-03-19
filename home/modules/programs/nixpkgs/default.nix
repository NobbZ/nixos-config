{
  config,
  lib,
  ...
}: let
  allowed = config.nixpkgs.allowedUnfree;
in {
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
    else (pkg: __elem (lib.getName pkg) allowed);
}
