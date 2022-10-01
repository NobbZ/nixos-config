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
  nix-output-monitor,
}: let
  runtimeDeps = [hostname coreutils nix home-manager nixos-rebuild ncurses6 nix-output-monitor];
in
  rustPlatform.buildRustPackage {
    pname = "nobbz-switcher";
    version = "0.2.2";

    nativeBuildInputs = [makeWrapper pkg-config];
    buildInputs = [openssl];

    src = ./.;

    cargoSha256 = "sha256-u4x7l4wTQ1E4D0IjHv2Nbj7McWyjduGNmAcMTTp2clk=";

    postInstall = ''
      wrapProgram $out/bin/switcher \
        --suffix PATH : "${lib.makeBinPath runtimeDeps}"
    '';
  }
