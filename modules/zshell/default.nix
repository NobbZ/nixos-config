{ config, lib, pkgs, ... }:

let
  cfg = config.programs.zshell;
  aliasesStr = lib.concatStringsSep "\n"
    (lib.mapAttrsToList (k: v: "alias ${k}=${lib.escapeShellArg v}")
      cfg.aliases);
in {
  options.programs.zshell = {
    aliases = lib.mkOption {
      default = { };
      example = {
        ll = "ls -l";
        ".." = "cd ..";
      };
      description = ''
        An attribute set that maps aliases (the top level attribute names in
        this option) to command strings or directly to build outputs.
      '';
      type = lib.types.attrsOf lib.types.str;
    };
  };

  config = {
    home.file = {
      ".zsh/boot/aliases.zsh" = {
        text = ''
          ${aliasesStr}
        '';
      };
    };
  };
}
