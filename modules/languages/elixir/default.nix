{ config, lib, pkgs, ... }:

let cfg = config.languages.elixir;

in {
  options.languages.elixir = {
    enable = lib.mkEnableOption "Enable support for elixir language";
  };

  config = lib.mkIf cfg.enable {
    programs.emacs.extraPackages = ep: [ ep.elixir-mode ];

    programs.emacs.lsp-mode = {
      enable = true;
      languages = [ "elixir" ];
    };

    programs.emacs.extraConfig = ''
      ;; Confire elixir related stuff
      (setq lsp-clients-elixir-server-executable
            '("${pkgs.bash}/bin/bash" "${pkgs.elixir-lsp}/bin/elixir-ls"))

      (add-hook 'elixir-mode-hook
                (lambda ()
                  (subword-mode)
                  (company-mode)
                  (flymake-mode)
                  (add-hook 'before-save-hook #'lsp-format-buffer nil t)))
    '';
  };
}
