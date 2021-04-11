{
  cachix = import ./cachix.nix;
  flake = import ./flake.nix;
  gc = import ./gc.nix;
  intel = import ./intel.nix;
  k3s = import ./k3s.nix;
  kubernetes = import ./kubernetes.nix;
  packet-iscsi = import ./packet-iscsi.nix;
  version = import ./version.nix;
  virtualbox-demo = import ./virtualbox-demo.nix;
}
