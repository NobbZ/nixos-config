_: {
  _file = ./zerotier.nix;

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = ["8286ac0e4768c8ae"];
}
