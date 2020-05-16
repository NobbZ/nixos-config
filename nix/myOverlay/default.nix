self: super:

let
  erlLib =
    super.callPackage <nixpkgs/pkgs/development/beam-modules/lib.nix> { };
in rec {
  advcp = super.callPackage (import ./advcp) { };
  asdf-vm = super.callPackage (import ./asdf) { };
  aur-tools = super.callPackage (import ./aur) { };
  direnv-nix = super.callPackage (import ./direnv-nix) { };
  elixir-lsp = super.callPackage (import ./elixir-lsp) { };
  erlang-ls = super.callPackage (import ./erlang-ls) { };
  keyleds = super.callPackage (import ./keyleds) { };

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
