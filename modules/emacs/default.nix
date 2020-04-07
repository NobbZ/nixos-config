{ config, lib, pkgs, ... }:

let
  emacsEnabled = config.programs.emacs.enable;
  cfg = config.programs.emacs;
  beaconEnabled = cfg.packages.beacon.enable;

  bool2Lisp = b: if b then "t" else "nil";

  lisps = lib.attrsets.mapAttrs' (k: v: {
    name = ".emacs.d/lisp/${k}.el";
    value = {
      text = pkgs.nobbzLib.emacs.generatePackage k v.tag v.comments v.requires
        v.code;
    };
  }) cfg.localPackages;

  lispRequires = let
    names = lib.attrsets.mapAttrsToList (n: _: n) cfg.localPackages;
    sorted = builtins.sort (l: r: l < r) names;
    required = builtins.map (r: "(require '${r})") sorted;
  in builtins.concatStringsSep "\n" required;

in {
  imports = [
    ./beacon.nix
    ./helm.nix
    ./polymode
    ./projectile.nix
    ./telephoneline.nix
    ./whichkey
  ];

  options.programs.emacs = {
    splashScreen = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enable the startup screen.
      '';
    };

    localPackages = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: {
        options = {
          tag = lib.mkOption { type = lib.types.str; };
          comments = lib.mkOption { type = lib.types.listOf lib.types.str; };
          requires = lib.mkOption { type = lib.types.listOf lib.types.str; };
          code = lib.mkOption { type = lib.types.str; };
        };
      }));
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra preferences to add to <filename>init.el</filename>.
      '';
    };

    module = lib.mkOption {
      description = "Attribute set of modules to link into emacs configuration";
      default = { };
    };
  };

  config = lib.mkIf emacsEnabled {
    programs.emacs.extraConfig = ''
            ;; adjust the load-path to find further down required files
            (add-to-list 'load-path
                         (expand-file-name "lisp" user-emacs-directory))

            ;; require all those local packages
            ${lispRequires}

      			(global-auto-revert-mode)
      			(global-whitespace-mode)
      			(global-linum-mode)

            ;; set splash screen
            (setq inhibit-startup-screen ${bool2Lisp (!cfg.splashScreen)})
          '';

    programs.emacs.extraPackages = ep: [
      ep.go-mode
      ep.company-go
      ep.markdown-mode
      ep.yaml-mode
    ];

    home.file = {
      ".emacs.d/init.el" = {
        text = pkgs.nobbzLib.emacs.generatePackage "init"
          "Initialises emacs configuration" [ ] [ ] cfg.extraConfig;
      };
    } // lisps;
  };
}
