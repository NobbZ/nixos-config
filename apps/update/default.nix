{
  self,
  unstable,
  ...
}: let
  pkgs = import unstable {system = "x86_64-linux";};
  type = "app";
  program = "${update}/bin/update";

  update = pkgs.stdenv.mkDerivation {
    pname = "nobbz-flake-updater";
    version = "0.0.1";

    buildInputs = [self.packages.x86_64-linux.zx];

    src = ./.;

    installPhase = ''
      mkdir -p $out/{bin,lib}

      cat <<EOF > $out/bin/update
        #!${pkgs.bash}/bin/bash

        exec $out/lib/update.mjs
      EOF
      chmod ugo=rx $out/bin/update

      install --mode=555 update.mjs $out/lib/update.mjs
    '';
  };
in {inherit type program;}
