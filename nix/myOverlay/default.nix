self: super:
let
  keepasspkgs = self.fetchFromGitHub {
    owner = "wnklmnn";
    repo = "nixpkgs";
    rev = "e1bcd10a071ef746e1078272913048b1eef4ceee";
    sha256 = "03bd52y51xr6fhy3r8xggq84z39p94mhipw6xyjnm1niq7iim7cw";
  };

  stable = import super.sources."nixpkgs-20.09" { };
in
rec {
  advcp = self.callPackage (import ./advcp) { };
  elixir-lsp = self.beam.packages.erlang.callPackage (import ./elixir-lsp) {
    rebar3 = stable.beam.packages.erlang.rebar3;
  };
  erlang-ls = super.beam.packages.erlang.callPackage (import ./erlang-ls) {
    # beamPackages = super.beam.packages.erlangR21;
  };
  keyleds = self.callPackage (import ./keyleds) { };
  ocaml-lsp = self.callPackage ./ocaml-ls { };
  rofi-unicode = self.callPackage ./rofi-unicode.nix { };
  nix-zsh-completions = super.nix-zsh-completions.overrideAttrs (_: {
    version = "overlay";
    src = self.fetchFromGitHub {
      owner = "Ma27";
      repo = "nix-zsh-completions";
      rev = "939c48c182e9d018eaea902b1ee9d00a415dba86";
      sha256 = "sha256-3HVYez/wt7EP8+TlhTppm968Wl8x5dXuGU0P+8xNDpo=";
    };
  });

  keepass =
    self.callPackage (keepasspkgs.outPath + "/pkgs/applications/misc/keepass")
      { };

  nobbzLib = (import ./lib);
} //
(super.lib.foldr
  (v: acc:
    acc // {
      "julia_${v}" = super."julia_${v}".overrideAttrs (_: { doCheck = false; });
    }))
  { }
  [ "15" "13" "10" ]
