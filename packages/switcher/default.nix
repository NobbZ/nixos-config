{rustPlatform}:
rustPlatform.buildRustPackage {
  pname = "nobbz-switcher";
  version = "0.1.0";

  src = ./.;

  cargoSha256 = "sha256-UWNgqQLWl/WJ1lZEg0arCHzwC06SYPYLNKnBcIxvDmQ=";
}
