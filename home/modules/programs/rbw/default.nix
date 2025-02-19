_: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.rbw;
in {
  config = lib.mkIf cfg.enable {
    programs.rbw.settings = {
      inherit (pkgs) pinentry;

      email = "timmelzer@gmail.com";
      base_url = "https://passwords.mimas.internal.nobbz.dev";
    };
  };
}
