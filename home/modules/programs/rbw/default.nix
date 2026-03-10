_: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.rbw;
  base_url = "https://passwords.mimas.internal.nobbz.dev";
in {
  config = lib.mkIf cfg.enable {
    programs.rbw.settings = {
      pinentry = pkgs.pinentry-curses;

      email = "timmelzer@gmail.com";
      base_url = base_url;
      ui_url = base_url;
    };
  };
}
