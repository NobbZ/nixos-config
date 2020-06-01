self: super:

let
  erlLib = self.callPackage <nixpkgs/pkgs/development/beam-modules/lib.nix> { };

  keepasspkgs = self.fetchFromGitHub {
    owner = "wnklmnn";
    repo = "nixpkgs";
    rev = "e1bcd10a071ef746e1078272913048b1eef4ceee";
    sha256 = "03bd52y51xr6fhy3r8xggq84z39p94mhipw6xyjnm1niq7iim7cw";
  };
in rec {
  advcp = self.callPackage (import ./advcp) { };
  asdf-vm = self.callPackage (import ./asdf) { };
  aur-tools = self.callPackage (import ./aur) { };
  direnv-nix = self.callPackage (import ./direnv-nix) { };
  elixir-lsp = self.callPackage (import ./elixir-lsp) { };
  erlang-ls = self.callPackage (import ./erlang-ls) { };
  keyleds = self.callPackage (import ./keyleds) { };
  ocaml-lsp = self.callPackage ./ocaml-ls { };

  keepass =
    self.callPackage (keepasspkgs.outPath + "/pkgs/applications/misc/keepass")
    { };

  erlangR23 = erlLib.callErlang ({ mkDerivation }:
    mkDerivation {
      version = "23.0";
      sha256 = "0hw0js0man58m5mdrzrig5q1agifp92wxphnbxk1qxxbl6ccs6ls";
      prePatch = ''
        substituteInPlace make/configure.in --replace '`sw_vers -productVersion`' "''${MACOSX_DEPLOYMENT_TARGET:-10.12}"
        substituteInPlace erts/configure.in --replace '-Wl,-no_weak_imports' ""
      '';
    }) { };

  beam = super.beam // {
    packages = super.beam.packages // {
      erlangR23 = self.beam.packagesWith erlangR23;
    };
  };

  nobbzLib = (import ./lib);
}
