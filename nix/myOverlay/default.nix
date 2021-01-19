final: prev:
let
  keepasspkgs = final.fetchFromGitHub {
    owner = "wnklmnn";
    repo = "nixpkgs";
    rev = "e1bcd10a071ef746e1078272913048b1eef4ceee";
    sha256 = "03bd52y51xr6fhy3r8xggq84z39p94mhipw6xyjnm1niq7iim7cw";
  };
in
rec {
  nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (_: {
    version = "overlay";
    src = final.fetchFromGitHub {
      owner = "Ma27";
      repo = "nix-zsh-completions";
      rev = "939c48c182e9d018eaea902b1ee9d00a415dba86";
      sha256 = "sha256-3HVYez/wt7EP8+TlhTppm968Wl8x5dXuGU0P+8xNDpo=";
    };
  });

  keepass =
    final.callPackage "${keepasspkgs}/pkgs/applications/misc/keepass" { };

  nobbzLib = (import ./lib);
} //
(prev.lib.foldr
  (v: acc:
    acc // {
      "julia_${v}" = prev."julia_${v}".overrideAttrs (_: { doCheck = false; });
    }))
  { }
  [ "15" "13" "10" ]
