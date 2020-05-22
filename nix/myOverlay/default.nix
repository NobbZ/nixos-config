self: super:

let
  erlLib = self.callPackage <nixpkgs/pkgs/development/beam-modules/lib.nix> { };
in rec {
  advcp = self.callPackage (import ./advcp) { };
  asdf-vm = self.callPackage (import ./asdf) { };
  aur-tools = self.callPackage (import ./aur) { };
  direnv-nix = self.callPackage (import ./direnv-nix) { };
  elixir-lsp = self.callPackage (import ./elixir-lsp) { };
  erlang-ls = self.callPackage (import ./erlang-ls) { };
  keyleds = self.callPackage (import ./keyleds) { };
  ocaml-lsp = self.callPackage ./ocaml-ls { };

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
