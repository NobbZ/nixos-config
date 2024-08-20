{nixpkgs-pre-rust, ...}: {
  config,
  pkgs,
  ...
}: {
  _file = ./zerotier.nix;

  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = ["8286ac0e4768c8ae"];

  services.zerotierone.localConf = {};

  services.zerotierone.package =
    (import nixpkgs-pre-rust {
      inherit (config.nixpkgs) config;
      inherit (pkgs) system;
    })
    .zerotierone;
}
