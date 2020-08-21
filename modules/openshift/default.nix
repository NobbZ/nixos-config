{ pkgs, lib, config, ... }:

let cfg = config.programs.openshift;

in {
  options.programs.openshift = {
    enable = lib.mkEnableOption "Tools to manage openshift instances";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.openshift pkgs.kubernetes-helm ];

    programs.zsh.initExtra = ''
      # Enable autocomplete for oc, kubectl and helm
      eval "$(${pkgs.openshift}/bin/oc completion zsh)"
      eval "$(${pkgs.openshift}/bin/kubectl completion zsh)"
      eval "$(${pkgs.kubernetes-helm}/bin/helm completion zsh)"
    '';
  };
}
