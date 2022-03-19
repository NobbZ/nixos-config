{
  config,
  lib,
  ...
}: let
  ecfg = config.programs.emacs;
in {
  config = lib.mkIf ecfg.enable {
    programs.emacs.localPackages."init-telephoneline" = {
      tag = "Setup telephone line";
      comments = [];
      requires = [];
      code = ''
        ;; set up telephone line
        (setq-default
         telephone-line-lhs '((accent . (telephone-line-vc-segment
                                         telephone-line-erc-modified-channels-segment
                                         telephone-line-process-segment))
                              (nil    . (telephone-line-minor-mode-segment
                                         telephone-line-buffer-segment)))
         telephone-line-rhs '((nil    . (telephone-line-misc-info-segment))
                              (accent . (telephone-line-major-mode-segment))
                              (accent . (telephone-line-airline-position-segment))))

        (telephone-line-mode t)
      '';
    };

    programs.emacs.extraPackages = ep: [ep.telephone-line];
  };
}
