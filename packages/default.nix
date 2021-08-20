{ self, emacs, ... }@inputs:

let
  pkgs = inputs.nixpkgs-2105.legacyPackages.x86_64-linux;
  upkgs = inputs.unstable.legacyPackages.x86_64-linux;
  mpkgs = inputs.master.legacyPackages.x86_64-linux;

  epkgs = import inputs.unstable { system = "x86_64-linux"; overlays = [ emacs.overlay ]; };
  nodePkgs = upkgs.callPackage ./nodePackages { };
in
{
  "advcp" = pkgs.callPackage ./advcp { };
  "gnucash-de" = upkgs.callPackage ./gnucash-de { };
  "keyleds" = upkgs.callPackage ./keyleds { };
  "dracula/konsole" = upkgs.callPackage ./dracula/konsole { };
  "emacs" = epkgs.emacsGcc;
  "emacsPgtkGcc" = epkgs.emacsPgtkGcc;
  "elixir-lsp" = upkgs.beam.packages.erlang.callPackage ./elixir-lsp { };
  "erlang-ls" = upkgs.beam.packages.erlang.callPackage ./erlang-ls { };
  "rofi/unicode" = upkgs.callPackage ./rofi-unicode { };
  "zx" = nodePkgs.zx;
}
