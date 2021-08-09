{ self, unstable, ... }:

let
  pkgs = import unstable { system = "x86_64-linux"; };
  type = "app";
  program = "${switch}/bin/switch";

  nixosConfigs = pkgs.writeText "nixosConfigs" ''
    ${__toJSON (__attrNames self.nixosConfigurations)}
  '';

  homeConfigs = pkgs.writeText "homeConfigs" ''
    ${__toJSON (__attrNames self.homeConfigurations)}
  '';

  switch = pkgs.stdenv.mkDerivation {
    pname = "nobbz-flake-switcher";
    version = "0.0.1";

    buildInputs = [ self.packages.x86_64-linux.zx ];

    src = ./.;

    installPhase = ''
      mkdir -p $out/{bin,lib}

      cat <<EOF > $out/bin/switch
        #!${pkgs.bash}/bin/bash

        exec $out/lib/switch.mjs --nixos ${nixosConfigs} --home ${homeConfigs} "\$@"
      EOF
      chmod ugo=rx $out/bin/switch

      install --mode=555 switch.mjs $out/lib/switch.mjs
    '';
  };
in
{ inherit type program; }
