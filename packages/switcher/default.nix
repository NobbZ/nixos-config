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
  openssl
}: let
  runtimeDeps = [gh hostname coreutils nix nixos-rebuild home-manager ncurses6];
in
  rustPlatform.buildRustPackage {
    pname = "nobbz-switcher";
    version = "0.2.0";

    nativeBuildInputs = [makeWrapper pkg-config];
    buildInputs = [openssl];

    src = ./.;

    cargoSha256 = "sha256-m8IlajRMidedjm+eyKJdasAOtrgZ6dTtaqYl1nJxLE8=";

    postInstall = ''
      wrapProgram $out/bin/switcher \
        --set PATH "${lib.makeBinPath runtimeDeps}:/run/wrappers/bin"
    '';
  }
