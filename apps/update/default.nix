{ self, unstable, ... }:

let
  pkgs = import unstable { system = "x86_64-linux"; };
  type = "app";
  program = "${update}/bin/update.mjs";

  update = pkgs.stdenv.mkDerivation {
    pname = "nobbz-flake-updater";
    version = "0.0.1";

    buildInputs = [ self.packages.x86_64-linux.zx ];

    src = ./.;

    installPhase = ''
      mkdir -p $out/bin

      install --mode=555 update.mjs $out/bin/update.mjs
      ls -l $out/bin
    '';
  };
in
{ inherit type program; }
