{ mkShell, gnumake, nixpkgs-fmt, git }:

mkShell {
  name = "nixos-builder";

  buildInputs = [ gnumake nixpkgs-fmt git ];

  shellHook = ''
    ${git}/bin/git fetch origin
  '';
}
