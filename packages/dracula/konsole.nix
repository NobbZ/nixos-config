{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dracula-konsole-theme";
  version = "fa85573";

  src = fetchFromGitHub {
    name = "${pname}-${version}-source";
    owner = "dracula";
    repo = "konsole";
    rev = version;
    sha256 = "sha256-375TOAOEx9FObS9F2tMYEyKboTYCZycawGoNEolZ0Ns=";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/konsole
    cp Dracula.colorscheme $out/share/konsole
  '';
}
