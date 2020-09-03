{ sources, srcOnly, lib, ... }:
let
  version = sources.asdf.version;
  pname = "asdf-vm";

in
srcOnly rec {
  # pname = "asdf-vm";
  # version = sources.asdf.version;
  name = "${pname}-${version}";

  src = sources.asdf;

  # meta = with lib; {
  #   inherit (sources.asdf) homepage description;
  #   license = licenses.mit;
  #   maintainers = [ maintainers.nobbz ];
  # };
}
