{ config, lib, pkgs, ... }:

let cfg = config.languages.terraform;

in {
  options.languages.terraform = {
    enable = lib.mkEnableOption "Enable support for the terraform lanugage";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      localPackages."init-terraform" = {
        tag = "Setup and prepare terraform editing modes";
        comments = [ ];
        requires = [ "company-terraform" ];
        packageRequires = ep: [ ep.company-terraform ep.terraform-mode ];
        code = ''
          (add-hook 'terraform-mode-hook
                    (lambda ()
                      (company-mode)
                      (company-terraform)))
        '';
      };
    };
  };
}
