{ sources, srcOnly, lib, ... }:

srcOnly rec {
  name = "asdf-vm";
  version = sources.asdf.version;

  src = sources.asdf;

  meta = with lib; {
    inherit (sources.asdf) homepage description;
    license = licenses.mit;
    maintainers = [ maintainers.nobbz ];
  };
}
