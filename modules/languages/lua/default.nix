{ config, lib, ... }:

let cfg = config.languages.lua;

in {
  options.languages.lua = {
    enable = lib.mkEnableOption "Enable support for lua language";
  };

  config =
    lib.mkIf cfg.enable { programs.emacs.extraPackages = ep: [ ep.lua-mode ]; };
}
