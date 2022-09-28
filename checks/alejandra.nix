{
  runCommand,
  alejandra,
  self,
}:
runCommand "alejandra-run-${self.rev or "00000000"}" {} ''
  ${alejandra}/bin/alejandra --check ${self} < /dev/null | tee $out
''
