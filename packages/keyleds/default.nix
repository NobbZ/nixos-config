{ pkgs, stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  name = "keyleds";
  version = "1.1.0";

  src = fetchFromGitHub {
    name = "source-${name}-${version}";
    owner = "keyleds";
    repo = "keyleds";
    rev = "v${version}";
    sha256 = "0ig4l9q5qgakya88z1rvziw0gyv329i5bbf32vgp71vyqdyysqr1";
  };

  nativeBuildInputs = with pkgs; [ cmake pkgconfig ];
  buildInputs = with pkgs; [ x11 xorg.libXi libuv systemd luajit libyaml ];
}
