{
  pkgs,
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation (self: {
  name = "keyleds";
  version = "1.1.1";

  src = fetchFromGitHub {
    name = "source-${self.name}-${self.version}";
    owner = "keyleds";
    repo = "keyleds";
    rev = "v${self.version}";
    sha256 = "sha256-KCWmaRmJTmZgTt7HW9o6Jt1u4x6+G2j6T9EqVt21U18=";
  };

  nativeBuildInputs = with pkgs; [cmake pkg-config];
  buildInputs = with pkgs; [xlibsWrapper xorg.libXi libuv systemd luajit libyaml];
})
