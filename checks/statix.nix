{
  runCommandNoCC,
  statix,
  self,
}:
runCommandNoCC "statix-run-${self.rev or "00000000"}" {} ''
  cd ${self}
  ${statix}/bin/statix check -i packages/nodePackages/node-env.nix | tee $out
''
