{ mkShell, gnumake, nixpkgs-fmt, git }:

mkShell {
  name = "nixos-builder";

  buildInputs = [ gnumake nixpkgs-fmt git ];
}
