{
  runCommandNoCC,
  alejandra,
  self,
}:
runCommandNoCC "alejandra-run-${self.rev or "00000000"}" {} ''
  ${alejandra}/bin/alejandra --check ${self} < /dev/null
''
