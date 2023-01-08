{stdenv}: let
  npins = import ../../../npins;
in
  stdenv.mkDerivation (self: {
    pname = "dracula-konsole-theme";
    version = npins.konsole.revision;

    src = npins.konsole;

    phases = ["unpackPhase" "installPhase"];

    installPhase = ''
      mkdir -p $out/share/konsole
      cp Dracula.colorscheme $out/share/konsole
    '';
  })
