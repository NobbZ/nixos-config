self: super:

let
  mkDerivation = super.stdenv.mkDerivation;
  fetchFromGitHub = super.fetchFromGitHub;

  keyleds = mkDerivation rec {
    name = "keyleds";
    version = "1.1.0";

    src = fetchFromGitHub {
      owner = "keyleds";
      repo = "keyleds";
      rev = "v${version}";
      sha256 = "0ig4l9q5qgakya88z1rvziw0gyv329i5bbf32vgp71vyqdyysqr1";
    };

    nativeBuildInputs = with self; [ cmake pkgconfig ];
    buildInputs = with self; [ x11 xorg.libXi libuv systemd luajit libyaml ];
  };

in { keyleds = keyleds; }
