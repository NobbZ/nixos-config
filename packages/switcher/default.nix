{
  lib,
  rustPlatform,
  makeWrapper,
  hostname,
  coreutils,
  nix,
  nixos-rebuild,
  home-manager,
  ncurses6,
  pkg-config,
  openssl,
}: let
  runtimeDeps = [hostname coreutils nix home-manager nixos-rebuild ncurses6];
in
  rustPlatform.buildRustPackage {
    pname = "nobbz-switcher";
    version = "0.2.1";

    nativeBuildInputs = [makeWrapper pkg-config];
    buildInputs = [openssl];

    src = ./.;

    cargoSha256 = "sha256-FsSqCdW0Y8GF6Ba82FN4iAmlSE3vZoOS9r1FhIdmjXo=";

    postInstall = ''
      wrapProgram $out/bin/switcher \
        --suffix PATH : "${lib.makeBinPath runtimeDeps}"
    '';
  }
