{modulesPath, ...}: {
  _file = ./base.nix;

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  isoImage = {
    edition = "nobbz";
    squashfsCompression = "zstd -Xcompression-level 10";
  };
}
