_: pkgs:

let
  asdf-vm-package = { sources, srcOnly, lib, ... }:
    srcOnly rec {
      pname = "asdf-vm";
      version = sources.asdf.version;
      name = "${pname}-${version}";

      src = sources.asdf;

      meta = with lib; {
        inherit (sources.asdf) homepage description;
        license = licenses.mit;
        maintainers = [ maintainers.nobbz ];
      };
    };

  asdf-vm-wrapper = { srcOnly, stdenv, pkgs, lib, ... }:
    stdenv.mkDerivation rec {
      name = "asdf-vm-wrapper";

      # phases = [ "installPhase" ];

      dontUnpack = true;

      buildInputs = [ pkgs.asdf-vm-package pkgs.zsh ];

      script = ./asdf-loader.sh;

      postBuild = ''
        substitute ${script} ${script}.out \
          --replace "%ZSH%" "${pkgs.zsh}"/bin/zsh \
          --replace "%ASDF_PACKAGE%" "${pkgs.asdf-vm-package}"
      '';

      installPhase = ''
        mkdir -p ''${out}/bin
        install -m755 ${script}.out ''${out}/bin/asdfloader
      '';

      meta = with lib; {
        homepage = "https://gitlab.com/NobbZ/nix-home-manager-dotfiles";
        description =
          "A wrapper that prints code that helps finding asdf-vm scripts";
        license = licenses.mit;
        maintainers = [ maintainers.nobbz ];
      };
    };
in {
  asdf-vm = pkgs.callPackage asdf-vm-wrapper { };
  asdf-vm-package = pkgs.callPackage asdf-vm-package { };
}
