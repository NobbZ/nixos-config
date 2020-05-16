self: super:

rec {
  advcp = super.callPackage (import ./advcp) { };
  asdf-vm = super.callPackage (import ./asdf) { };
  aur-tools = super.callPackage (import ./aur) { };
  direnv-nix = super.callPackage (import ./direnv-nix) { };
  elixir-lsp = super.callPackage (import ./elixir-lsp) { };
  erlang-ls = super.callPackage (import ./erlang-ls) { };
  keyleds = super.callPackage (import ./keyleds) { };

  erlangR23 = self.lib.callErlang ({ mkDerivation }:
    mkDerivation {
      version = "23.0";
      sha256 = self.lib.fakeSha256;
      prePatch = ''
        substituteInPlace make/configure.in --replace '`sw_vers -productVersion`' "''${MACOSX_DEPLOYMENT_TARGET:-10.12}"
        substituteInPlace erts/configure.in --replace '-Wl,-no_weak_imports' ""
      '';
    });

  beam = super.beam.overrideAttrs (oa: {
    packages = oa.packages // { erlangR23 = oa.packagesWith erlangR23; };
  });

  nobbzLib = (import ./lib);
}
