{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "nobbz-switcher";
  version = "0.1.0";

  src = ./.;

  cargoSha256 = "sha256-4HslCd3AMGZGFfADbQ/sdL9bj+R8woS8i0A9vKF1FgU=";
}
