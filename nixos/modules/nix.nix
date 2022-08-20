_: {
  config,
  lib,
  ...
}: let
  allowed = config.nix.allowedUnfree;
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
    (lib.mkIf (allowed != []) {nixpkgs.config.allowUnfreePredicate = pkg: __elem (lib.getName pkg) allowed;})
    {nix.settings.auto-optimise-store = lib.mkDefault true;}
    {
      nix.gc.automatic = lib.mkDefault true;
      nix.gc.options = lib.mkDefault "--delete-older-than 10d";
      nix.settings.allow-import-from-derivation = lib.mkDefault false;
    }
  ];
}
