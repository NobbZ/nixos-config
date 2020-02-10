{ lib, srcOnly, ... }:

srcOnly rec {
  pname = "aursync-helpers";
  version = "1";
  name = "${pname}-${version}";

  src = lib.cleanSource ./.;
}
