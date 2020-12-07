{ config, pkgs, unstable, ... }:

{
  services.k3s = {
    enable = true;
    package = unstable.legacyPackages.x86_64-linux.k3s;
    role = "server";
    docker = true;
    extraFlags = "--write-kubeconfig-mode 644 --disable traefik --default-local-storage-path /opt/local-path-provisioner";
  };

  systemd.services.k3s.path = [ pkgs.zfs ];

  #  TODO: re-enable firewall once learned how to do with k3s
  # systemd.services.firewall.enable = false;
}
