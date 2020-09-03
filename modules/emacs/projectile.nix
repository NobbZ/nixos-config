{ config, lib, ... }:
let emacsCfg = config.programs.emacs;
in
{
  config = lib.mkIf emacsCfg.enable {
    programs.emacs = {
      localPackages."init-projectile" = {
        tag = "Setup projectile";
        comments = [ ];
        requires = [ "projectile" "helm-projectile" "tramp" ];
        packageRequires = ep: [ ep.projectile ep.helm-projectile ];
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
