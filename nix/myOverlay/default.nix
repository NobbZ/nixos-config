self: super:
let
  erlLib = self.callPackage <nixpkgs/pkgs/development/beam-modules/lib.nix> { };

  keepasspkgs = self.fetchFromGitHub {
    owner = "wnklmnn";
    repo = "nixpkgs";
    rev = "e1bcd10a071ef746e1078272913048b1eef4ceee";
    sha256 = "03bd52y51xr6fhy3r8xggq84z39p94mhipw6xyjnm1niq7iim7cw";
  };
in
rec {
  advcp = self.callPackage (import ./advcp) { };
  direnv-nix = self.callPackage (import ./direnv-nix) { };
  elixir-lsp = self.beam.packages.erlang.callPackage (import ./elixir-lsp) { };
  erlang-ls = super.beam.packages.erlang.callPackage (import ./erlang-ls) {
    # beamPackages = super.beam.packages.erlangR21;
  };
  keyleds = self.callPackage (import ./keyleds) { };
  ocaml-lsp = self.callPackage ./ocaml-ls { };
  rofi-unicode = self.callPackage ./rofi-unicode.nix { };

  keepass =
    self.callPackage (keepasspkgs.outPath + "/pkgs/applications/misc/keepass")
      { };

  nobbzLib = (import ./lib);
}
