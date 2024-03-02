_: {
  _file = ./default.nix;

  nobbz.nixosConfigurations.mimas.system = "x86_64-linux";
  nobbz.nixosConfigurations.enceladeus.system = "x86_64-linux";
  nobbz.nixosConfigurations.hyperion.system = "aarch64-linux";
}
