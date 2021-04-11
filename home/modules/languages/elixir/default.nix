{ config, lib, pkgs, ... }:
let
  cfg = config.languages.elixir;

  inherit (pkgs.inputs.self.packages.${pkgs.system}) elixir-lsp;
in
{
  options.languages.elixir = {
    enable = lib.mkEnableOption "Enable support for elixir language";
  };

  config = lib.mkIf cfg.enable {
    programs.zshell.aliases = {
      mdg = "mix deps.get";
      mic = "mix compile";
      mit = "mix test";
    };

    programs.emacs = {
      lsp-mode = {
        enable = true;
        languages = [ "elixir" ];
      };

      localPackages."init-elixir" = {
        tag = "Setup elixir";
        comments = [ ];
        requires = [ "company" "flycheck" ];
        packageRequires = ep: [
          ep.company
          ep.elixir-mode
          ep.flycheck
          ep.lsp-mode
        ];
        code = ''
          (add-to-list 'exec-path "${elixir-lsp}/bin")
          (setq lsp-clients-elixir-server-executable "elixir-ls")

          (add-hook 'elixir-mode-hook
                    (lambda ()
                      (subword-mode)
                      (company-mode)
                      (flycheck-mode)
                      (lsp-lens-mode)
                      (add-hook 'before-save-hook #'lsp-format-buffer nil t)))
        '';
      };
    };
  };
}
