{ self, ... }@inputs:

{
  mimas = self.lib.mkSystem "mimas" inputs.nixpkgs-2105;
  enceladeus = self.lib.mkSystem "enceladeus" inputs.unstable;
}
