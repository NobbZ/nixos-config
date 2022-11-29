_: {
  config,
  lib,
  ...
}: let
  allowed = config.nix.allowedUnfree;
  kibibyte = 1024;
  mibibyte = 1024 * kibibyte;
  gibibyte = 1024 * mibibyte;
in {
  options.nix = {
    allowedUnfree = lib.mkOption {
      type = lib.types.listOf lib.types.string;
      default = [];
      description = ''
        Allows for  unfree packages by their name.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (allowed != []) {nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed;})
    {nix.settings.auto-optimise-store = lib.mkDefault true;}
    {
      nix.settings.min-free = lib.mkDefault (5 * gibibyte);
      nix.settings.max-free = lib.mkDefault (25 * gibibyte);
      nix.settings.allow-import-from-derivation = lib.mkDefault false;
    }
  ];
}
