{ config, lib, ... }:

let emacsCfg = config.programs.emacs;
in {
  config = lib.mkIf emacsCfg.enable {
    programs.emacs = {
      extraPackages = ep: [ ep.projectile ep.helm-projectile ];

      localPackages."init-projectile" = {
        tag = "Setup projectile";
        comments = [ ];
        requires = [ "projectile" "helm-projectile" ];
        code = ''
          ;; enable projectile
          (projectile-mode t)
          (helm-projectile-on)

          (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
        '';
      };
    };
  };
}
