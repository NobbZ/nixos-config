{
  mkShell,
  nixpkgs-fmt,
  git,
}:
mkShell {
  name = "system-and-home-builder";

  buildInputs = [nixpkgs-fmt git];

  shellHook = ''
    ${git}/bin/git fetch origin
  '';
}
