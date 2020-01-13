let pkgs = import ./nix { };
in pkgs.mkShell rec { nativeBuildInputs = with pkgs; [ niv ]; }
