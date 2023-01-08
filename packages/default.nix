{
  self,
  emacs,
  ...
} @ inputs: system: let
  pkgs = inputs.nixpkgs-2105.legacyPackages."${system}";
  upkgs = inputs.unstable.legacyPackages."${system}";

  epkgs = import inputs.unstable {
    inherit system;
    overlays = [emacs.overlay];
  };
  nodePkgs = upkgs.callPackages ./nodePackages/override.nix {};

  nilBasePackage =
    if upkgs.stdenv.isLinux
    then inputs.nil.packages.${system}.nil
    else upkgs.nil;

  rnil-lsp = upkgs.writeShellScriptBin "rnix-lsp" ''
    exec ${nilBasePackage}/bin/nil "$@"
  '';

  nil = upkgs.symlinkJoin {
    name = "nil";
    paths = [nilBasePackage rnil-lsp];
  };
  # npins = import ../npins;
in
  {
    inherit nil;

    "advcp" = upkgs.callPackage ./advcp {};
    "dracula/konsole" = upkgs.callPackage ./dracula/konsole {};
    "emacs" = epkgs.emacsUnstable;
    "rofi/unicode" = upkgs.callPackage ./rofi-unicode {};
    "zx" = upkgs.nodePackages.zx;
    "angular" = nodePkgs."@angular/cli";

    "switcher" = upkgs.callPackage ./switcher {
      inherit (inputs.nix.packages."${system}") nix;
      inherit (inputs.home-manager.packages."${system}") home-manager;
    };

    "alejandra" = inputs.alejandra.defaultPackage."${system}";
  }
  // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
    "gnucash-de" = upkgs.callPackage ./gnucash-de {};
  }
  // pkgs.lib.optionalAttrs (system == "x86_64-linux") {
    "google-chrome" =
      (import inputs.master {
        inherit system;
        config.allowUnfree = true;
        config.google-chrome.enableWideVine = true;
      })
      .google-chrome;
  }
