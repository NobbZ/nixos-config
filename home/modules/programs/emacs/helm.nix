_: {
  config,
  lib,
  ...
}: let
  emacsCfg = config.programs.emacs;
in {
  config = lib.mkIf emacsCfg.enable {
    programs.emacs = {
      localPackages."init-helm" = {
        tag = "Setup helm";
        comments = [];
        requires = ["helm"];
        packageRequires = ep: [ep.helm ep.helm-rg];
        code = ''
          ;; enable and configure auto resize
          (helm-autoresize-mode t)
          (setq-default
           helm-autoresize-max-height 20  ; take at most 20% of the screen
           helm-autoresize-min-height  1) ; get as small as necessary

          ;; set up key bindings
          (global-set-key (kbd "M-x")     'helm-M-x)
          (global-set-key (kbd "C-x C-f") 'helm-find-files)
          (global-set-key (kbd "C-x C-b") 'helm-buffers-list)

          ;; enable helm
          (helm-mode t)
        '';
      };
    };
  };
}
