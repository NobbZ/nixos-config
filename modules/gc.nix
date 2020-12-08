{ config, lib, pkgs, ... }:

{
  options.programs.gc = {
    enable = lib.mkEnableOption "enable GC tool";

    maxAge = lib.mkOption {
      type = lib.types.string;
      default = "180d";
    };
  };

  config = lib.mkIf config.programs.gc.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "gc" ''
        sudo ${config.nix.package}/bin/nix-collect-garbage --delete-older-than ${config.programs.gc.maxAge} --verbose
      '')
    ];
  };
}
