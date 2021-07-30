{ config, lib, ... }:

let
  allowed = config.nix.allowedUnfree;
in
{
  options.nix = {
    experimentalFeatures = lib.mkOption {
      type = lib.types.separatedString " ";
      default = "";
      description = ''
        Enables experimental features
      '';
    };

    allowedUnfree = lib.mkOption {
      type = lib.types.listOf lib.types.string;
      default = [ ];
      description = ''
        Allows for  unfree packages by their name.
      '';
    };
  };

  config.nix.extraOptions = lib.mkIf (config.nix.experimentalFeatures != "") ''
    experimental-features = ${config.nix.experimentalFeatures}
  '';

  config.nix.autoOptimiseStore = lib.mkDefault true;

  config.nixpkgs.config.allowUnfreePredicate =
    if (allowed == [ ])
    then (_: false)
    else (pkg: __elem (lib.getName pkg) allowed);
}
