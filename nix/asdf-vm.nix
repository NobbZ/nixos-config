_: pkgs:

let
  asdf-vm-package = { sources, srcOnly, lib, ... }:
    srcOnly rec {
      name = "asdf-vm";
      pname = "${name}-${version}";
      version = sources.asdf.version;

      src = sources.asdf;

      meta = with lib; {
        inherit (sources.asdf) homepage description;
        license = licenses.mit;
        maintainers = [ maintainers.nobbz ];
      };
    };
in { asdf-vm = pkgs.callPackage asdf-vm-package { }; }
