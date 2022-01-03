{ config, lib, pkgs, ... }:
let
  emacsEnabled = config.programs.emacs.enable;
  cfg = config.programs.emacs;

  bool2Lisp = b: if b then "t" else "nil";

  confPackages =
    let
      fileContent = lib.attrsets.mapAttrs'
        (k: v: {
          name = "${k}";
          value = {
            ep = v.packageRequires;
            src = config.lib.emacs.generatePackage k v.tag v.comments v.requires
              v.code;
          };
        })
        cfg.localPackages;
      derivations = lib.attrsets.mapAttrs
        (k: v: {
          # ep = v.ep;
          inherit (v) ep;
          src = pkgs.writeText "${k}.el" v.src;
        })
        fileContent;
    in
    derivations;

  lispRequires =
    let
      names = lib.attrsets.mapAttrsToList (n: _: n) cfg.localPackages;
      sorted = builtins.sort (l: r: l < r) names;
      required = builtins.map (r: "(require '${r})") sorted;
    in
    builtins.concatStringsSep "\n" required;

in
{
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
      type = lib.types.attrsOf (lib.types.submodule (_: {
        options = {
          tag = lib.mkOption { type = lib.types.str; };
          comments = lib.mkOption { type = lib.types.listOf lib.types.str; };
          requires = lib.mkOption { type = lib.types.listOf lib.types.str; };
          code = lib.mkOption { type = lib.types.str; };
          packageRequires = lib.mkOption {
            type = lib.types.unspecified;
            default = _: [ ];
          };
        };
      }));
    };

    extraInit = lib.mkOption {
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
    programs.emacs.extraInit = ''
      ;; adjust the load-path to find further down required files
      (add-to-list 'load-path
      (expand-file-name "lisp" user-emacs-directory))

      (fset 'yes-or-no-p 'y-or-n-p)

      ;; Move backups and autosaves out of the way
      (setq backup-directory-alist
            `((".*" . ,temporary-file-directory)))
      (setq auto-save-file-name-transforms
            `((".*" ,temporary-file-directory)))

      ;; use a dark theme
      (load-theme 'dracula t)

      ;; Set a font
      (add-to-list 'default-frame-alist
                   '(font . "Cascadia Code PL-10"))

      ;; require all those local packages
      ${lispRequires}
      (require 'pest-mode)
      (add-to-list #'auto-mode-alist '("\\.pest\\'" . pest-mode))

      (global-auto-revert-mode)
      (global-whitespace-mode)
      (global-linum-mode)

      (setq-default indent-tabs-mode nil)
      (setq-default tab-width 2)
      (setq-default whitespace-style
                    '(face
                      tabs
                      spaces
                      trailing
                      lines-tail
                      newline
                      missing-newline-at-eof
                      space-before-tab
                      indentation
                      empty
                      space-after-tab
                      space-mark
                      tab-mark
                      newline-mark))

      ;; set splash screen
      (setq inhibit-startup-screen ${bool2Lisp (!cfg.splashScreen)})
    '';

    programs.emacs.extraPackages = ep:
      [
        ep.company-go
        ep.dracula-theme
        ep.docker-compose-mode
        ep.dockerfile-mode
        ep.go-mode
        ep.markdown-mode
        ep.yaml-mode
        ep.adoc-mode
        ep.k8s-mode
        ep.buttercup
        ep.adoc-mode
        ep.hledger-mode
        ep.typescript-mode
        ep.earthfile-mode
        ep.ledger-mode
        ep.pest-mode

        # ep.bazel-mode

        # (ep.trivialBuild { pname = "configuration"; src = confPackages; })
      ] ++ lib.attrsets.mapAttrsToList
        (pname: v:
          ep.trivialBuild {
            inherit pname;
            inherit (v) src;
            # src = v.src;
            packageRequires = v.ep ep;
          })
        confPackages;

    home.file = {
      ".emacs.d/init.el" = {
        text = config.lib.emacs.generatePackage "init"
          "Initialises emacs configuration" [ ] [ ]
          cfg.extraInit;
      };
    };
  };
}
