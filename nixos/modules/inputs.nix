{config, lib, ..., }: let
  cfg = config.flakeInputs;
  enabled = cfg.inputs != {} && cfg.inputs != null;
in {
  _file = ./inputs.nix;

  options.flakeInputs = {
    inputs = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.unspecified);
      default = null;
    };

    nixpkgs = lib.mkOption {
      type = lib.types.listOf lib.types.string;
      default = ["nixpkgs"];
    }

    nobbzFlake = lib.mkOption {
      type = lib.types.nullOr lib.types.string;
    };
  };

  config = lib.mkIf enabled {
    _module.args.packages = 
  };
}