{ config, lib, ... }:

let cfg = config.programs.emacs.lsp-mode;

    mode-hooks = with lib; let
      sorted = builtins.sort (l: r: l < r) cfg.languages;
      uni = unique sorted;
      hooks = builtins.map (l: "'${l}-mode-hook") uni;
      add-hooks = builtins.map (h: "(add-hook ${h} #'lsp)") hooks;
    in builtins.concatStringsSep "\n" add-hooks;

in {
  options.programs.emacs.lsp-mode = {
    enable = lib.mkEnableOption "Enables and installs lsp-mode";

    languages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        The prefixes of the prog-mode that shall be handled through lsp-mode.
      '';
      example = [ "erlang" ];
    };
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      localPackages."init-lsp" = {
        tag = "Setup and prepare the LSP mode";
        comments = [];
        requires = [ "lsp-mode" ];
        code = ''
          ${mode-hooks}
        '';
      };

      extraPackages = ep: [ ep.lsp-mode ];
    };
  };
}
