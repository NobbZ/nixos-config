{ self, ... }@inputs:

{
  mimas = self.lib.mkSystem "mimas" inputs.nixpkgs-2105;
}
