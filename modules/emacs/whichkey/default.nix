{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.emacs.whichkey;
  enabled = config.programs.emacs.enable;

  keyReplacementType = types.listOf (types.submodule ({ config, ... }: {
    options = {
      keys = lib.mkOption {
        type = types.str;
        description = ''
          Keys that shall get a description.
        '';
      };
      replace = lib.mkOption {
        type = types.str;
        description = ''
          Human readable description for the keycombination
        '';
      };
    };
  }));

  replacements = lib.concatStringsSep "\n  "
    (builtins.map ({ keys, replace, ... }: ''"${keys}" "${replace}"'')
      cfg.replacement);
in {
  options.programs.emacs.whichkey = {
    replacement = lib.mkOption { type = keyReplacementType; };
  };

  config = lib.mkIf enabled {
    programs.emacs.whichkey.replacement = [
      {
        keys = "C-x C-f";
        replace = "find file";
      }
      {
        keys = "C-x C-s";
        replace = "write file";
      }
      {
        keys = "C-x C-c";
        replace = "leave emacs";
      }
    ];
    programs.emacs.extraPackages = ep: [ ep.which-key ];
    programs.emacs.extraConfig = ''
      ;; which-key
      (which-key-mode t)
      (setq-default which-key-idle-delay 0.1)

      (which-key-add-key-based-replacements
        ${replacements})
    '';
  };
}
