{
  runCommand,
  statix,
  self,
}:
runCommand "statix-run-${self.rev or "00000000"}" {} ''
  cd ${self}
  ${statix}/bin/statix check | tee $out
''
