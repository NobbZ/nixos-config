{
  self,
  emacs,
  ...
} @ inputs: system: let
  pkgs = inputs.nixpkgs-2105.legacyPackages."${system}";
  upkgs = inputs.unstable.legacyPackages."${system}";
  mpkgs = inputs.master.legacyPackages."${system}";

  epkgs = import inputs.unstable {
    inherit system;
    overlays = [emacs.overlay];
  };
  nodePkgs = upkgs.callPackages ./nodePackages/override.nix {};
in {
  "advcp" = upkgs.callPackage ./advcp {};
  "dracula/konsole" = upkgs.callPackage ./dracula/konsole {};
  "emacs" = epkgs.emacsNativeComp;
  "elixir-lsp" = upkgs.elixir_ls;
  "erlang-ls" = upkgs.beam.packages.erlang.callPackage ./erlang-ls {};
  "rofi/unicode" = upkgs.callPackage ./rofi-unicode {};
  "zx" = upkgs.nodePackages.zx;
  "angular" = nodePkgs."@angular/cli";

  "switcher" = upkgs.callPackage ./switcher {
    inherit (inputs.nix.packages."${system}") nix;
    inherit (inputs.home-manager.packages."${system}") home-manager;
  };

  "alejandra" = inputs.alejandra.defaultPackage."${system}";
  "nil" = upkgs.writeShellScriptBin "rnix-lsp" ''
    exec ${inputs.nil.packages.${system}.nil}/bin/nil "$@"
  '';
} // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
  "google-chrome" =
    (import inputs.master {
      inherit system;
      config.allowUnfree = true;
      config.google-chrome.enableWideVine = true;
    })
    .google-chrome;

  "gnucash-de" = upkgs.callPackage ./gnucash-de {};
  "keyleds" = upkgs.callPackage ./keyleds {};
}
