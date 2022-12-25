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
    version = "0.2.3";

    nativeBuildInputs = [makeWrapper pkg-config];
    buildInputs = [openssl];

    src = ./.;

    cargoSha256 = "sha256-XpKmd4KOUBB96oIzPypYyBKfqc4Wm6BWTsf+lxbtdVE=";

    postInstall = ''
      wrapProgram $out/bin/switcher \
        --suffix PATH : "${lib.makeBinPath runtimeDeps}"
    '';
  }
