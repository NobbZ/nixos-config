{ lib, system }:

lib.nixosSystem {
  inherit system;

  modules = [
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
      ];

      services.lvm = {
        boot.thin.enable = true;
        dmeventd.enable = true;
      };
    })
  ];
}