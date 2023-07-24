{
  nixosSystem,
  system,
}:
nixosSystem {
  inherit system;

  modules = [
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
      ];

      services.lvm = {
        boot.thin.enable = true;
        boot.vdo.enable = true;
        dmeventd.enable = true;
      };

      isoImage.squashfsCompression = "zstd -Xcompression-level 10";
    })
  ];
}
