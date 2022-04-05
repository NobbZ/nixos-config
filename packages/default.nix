{
  self,
  emacs,
  ...
} @ inputs: let
  pkgs = inputs.nixpkgs-2105.legacyPackages.x86_64-linux;
  upkgs = inputs.unstable.legacyPackages.x86_64-linux;
  mpkgs = inputs.master.legacyPackages.x86_64-linux;

  epkgs = import inputs.unstable {
    system = "x86_64-linux";
    overlays = [emacs.overlay];
  };
  nodePkgs = upkgs.callPackages ./nodePackages/override.nix {};
in {
  "advcp" = pkgs.callPackage ./advcp {};
  "gnucash-de" = upkgs.callPackage ./gnucash-de {};
  "keyleds" = upkgs.callPackage ./keyleds {};
  "dracula/konsole" = upkgs.callPackage ./dracula/konsole {};
  "emacs" = epkgs.emacsGcc;
  "elixir-lsp" = upkgs.beam.packages.erlang.callPackage ./elixir-lsp {};
  "erlang-ls" = upkgs.beam.packages.erlang.callPackage ./erlang-ls {};
  "rofi/unicode" = upkgs.callPackage ./rofi-unicode {};
  "zx" = upkgs.nodePackages.zx;
  "angular" = nodePkgs."@angular/cli";

  "switcher" = upkgs.callPackage ./switcher {
    nix = inputs.nix.packages.x86_64-linux.nix;
    home-manager = inputs.home-manager.packages.x86_64-linux.home-manager;
  };

  "rnix-lsp" = inputs.rnix-lsp.defaultPackage.x86_64-linux;
  "statix" = inputs.statix.defaultPackage.x86_64-linux;
  "alejandra" = inputs.alejandra.defaultPackage.x86_64-linux;
}
