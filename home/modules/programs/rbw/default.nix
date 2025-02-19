_: {config, lib, pkgs, ...}: let cfg = config.programs.rbw; in {
  config = lib.mkIf cfg.enable {
    programs.rbw.settings = {
      email = "timmelzer@gmail.com";
      base_url = "https://passwords.mimas.internal.nobbz.dev";
      pinentry = pkgs.pinentry;
    };
  };
}
