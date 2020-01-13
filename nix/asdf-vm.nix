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
in { asdf-vm = pkgs.callPackage asdf-vm-package { }; }
