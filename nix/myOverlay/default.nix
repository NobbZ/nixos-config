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
  keepass =
    final.callPackage (keepasspkgs.outPath + "/pkgs/applications/misc/keepass")
      { };

  nobbzLib = (import ./lib);
} //
(prev.lib.foldr
  (v: acc:
    acc // {
      "julia_${v}" = prev."julia_${v}".overrideAttrs (_: { doCheck = false; });
    }))
  { }
  [ "15" "13" "10" ]
