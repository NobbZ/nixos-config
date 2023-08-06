{
  nixosSystem,
  system,
}:
nixosSystem {
  inherit system;

  modules = [
    ({modulesPath, ...}: {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
      ];

      isoImage = {
        edition = "nobbz";
        squashfsCompression = "zstd -Xcompression-level 10";
      };

      services.xserver = {
        windowManager.awesome.enable = true;
        displayManager.sddm.enable = true;
        displayManager.autoLogin.enable = true;
        displayManager.autoLogin.user = "nixos";
      };

      services.lvm = {
        boot.thin.enable = true;
        boot.vdo.enable = true;
        dmeventd.enable = true;
      };
    })
  ];
}
