{ config, lib, ... }:

{
  options.nix.experimentalFeatures = lib.mkOption {
    type = lib.types.separatedString " ";
    default = "";
    description = ''
      Enables experimental features
    '';
  };

  config = lib.mkIf (config.nix.experimentalFeatures != "") {
    nix.extraOptions = ''
      experimental-features = ${config.nix.experimentalFeatures}
    '';
  };
}
