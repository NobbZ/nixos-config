{
  self,
  unstable,
  ...
}: let
  pkgs = unstable.legacyPackages.x86_64-linux;
  type = "app";
  program = "${update}/bin/update";

  inherit (pkgs) lib;

  ruby = pkgs.ruby.withPackages (rp: []);

  update = pkgs.stdenv.mkDerivation {
    pname = "nobbz-flake-updater";
    version = "0.0.2";

    buildInputs = [ruby];

    src = ./.;

    installPhase = ''
      mkdir -p $out/{bin,lib}

      cat <<EOF > $out/bin/update
        #!${pkgs.bash}/bin/bash

        export PATH=${lib.makeBinPath [pkgs.git]}:$PATH

        exec $out/lib/update.rb
      EOF
      chmod ugo=rx $out/bin/update

      install --mode=555 update.rb $out/lib/update.rb
    '';
  };
in {inherit type program;}
