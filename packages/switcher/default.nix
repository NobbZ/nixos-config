{
  lib,
  rustPlatform,
  makeWrapper,
  gh,
  hostname,
  coreutils,
  nix,
  nixos-rebuild,
  home-manager,
  ncurses6,
  pkg-config,
  openssl,
}: let
  runtimeDeps = [hostname coreutils nix home-manager ncurses6];
in
  rustPlatform.buildRustPackage {
    pname = "nobbz-switcher";
    version = "0.2.0";

    nativeBuildInputs = [makeWrapper pkg-config];
    buildInputs = [openssl];

    src = ./.;

    cargoSha256 = "sha256-1sWA3Au/OjWeBR8dU+PT4TBGZ0Bs+Wpqgrq+8UpL+wo=";

    postInstall = ''
      wrapProgram $out/bin/switcher \
        --set PATH "${lib.makeBinPath runtimeDeps}:/run/wrappers/bin"
    '';
  }
